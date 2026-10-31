import io
import logging
import re
import time
from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI, File, HTTPException, Request, UploadFile
from PIL import Image, ImageOps, UnidentifiedImageError
from pydantic import ValidationError

from app import config, prompts
from app.razones import frase_siembra
from app.llm import LLMError, LLMNoDisponible, Proveedor, crear_proveedores, extraer_json
from app.schemas import AnalisisRespuesta, ExplicarEntrada, ExplicarRespuesta, ParcelaAnalisis

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s: %(message)s")
log = logging.getLogger("lunisa")

FORMATOS_PERMITIDOS = {"JPEG", "PNG", "WEBP"}
MAX_INTENTOS = 2  # el primero + un reintento
FRASE_FUENTE = {"foto": "se ve en la foto", "campesino": "nos lo dijo el campesino", "datos": "datos del municipio"}


class RespuestaInvalida(Exception):
    """El modelo no devolvió un JSON válido tras MAX_INTENTOS."""


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Falla al arrancar (no en la primera petición) si la config es inválida
    app.state.proveedores = crear_proveedores()
    log.info("Proveedores: %s", {n: p.modelo for n, p in app.state.proveedores.items()})
    log.info("Análisis → %s | Explicar → %s", config.PROVEEDOR_ANALISIS, config.PROVEEDOR_EXPLICAR)
    yield


app = FastAPI(title="Lu-nisa backend", version="0.2.0", lifespan=lifespan)


def obtener_proveedores(request: Request) -> dict[str, Proveedor]:
    return request.app.state.proveedores


def ms_desde(inicio: float) -> int:
    return round((time.perf_counter() - inicio) * 1000)


def preparar_imagen(datos: bytes) -> bytes:
    """Valida que sea jpeg/png/webp y la reduce a LADO_MAX_IMAGEN px como JPEG."""
    try:
        img = Image.open(io.BytesIO(datos))
        formato = img.format
        img.load()
    except (UnidentifiedImageError, OSError):
        raise HTTPException(415, {"error": "imagen_invalida", "detalle": "No se pudo leer el archivo como imagen"})
    if formato not in FORMATOS_PERMITIDOS:
        raise HTTPException(415, {"error": "formato_no_soportado", "detalle": f"{formato}; usa jpeg, png o webp"})

    # Las fotos de celular traen la rotación en EXIF
    img = ImageOps.exif_transpose(img).convert("RGB")
    img.thumbnail((config.LADO_MAX_IMAGEN, config.LADO_MAX_IMAGEN))
    salida = io.BytesIO()
    img.save(salida, format="JPEG", quality=85)
    return salida.getvalue()


def errores_llm(e: Exception) -> HTTPException:
    if isinstance(e, LLMNoDisponible):
        return HTTPException(503, {"error": "llm_no_disponible", "detalle": str(e)})
    return HTTPException(502, {"error": "llm_error", "detalle": str(e)})


@app.get("/salud")
async def salud(proveedores: dict[str, Proveedor] = Depends(obtener_proveedores)):
    return {
        "analisis": config.PROVEEDOR_ANALISIS,
        "explicar": config.PROVEEDOR_EXPLICAR,
        "proveedores": {n: await p.salud() for n, p in proveedores.items()},
    }


async def analizar_con(llm: Proveedor, jpeg: bytes) -> tuple[ParcelaAnalisis, int]:
    """Pide el análisis a un proveedor; reintenta una vez si la respuesta no es válida."""
    prompt = prompts.PROMPT_PARCELA
    error = ""
    for intento in range(1, MAX_INTENTOS + 1):
        texto = await llm.generar(prompt, sistema=prompts.SISTEMA_PARCELA, imagen=jpeg, json_mode=True)
        try:
            return ParcelaAnalisis.model_validate(extraer_json(texto)), intento
        except ValueError as e:
            # ValidationError y json.JSONDecodeError heredan de ValueError
            error = str(e)
            log.warning("[%s] intento %d inválido: %s | respuesta: %r", llm.nombre, intento, error, texto[:300])
            prompt = prompts.PROMPT_PARCELA + "\n\n" + prompts.PROMPT_CORRECCION.format(error=error)
    raise RespuestaInvalida(f"{llm.nombre} no devolvió un JSON válido tras {MAX_INTENTOS} intentos: {error}")


@app.post("/analizar-parcela", response_model=AnalisisRespuesta)
async def analizar_parcela(
    imagen: UploadFile = File(...), proveedores: dict[str, Proveedor] = Depends(obtener_proveedores)
):
    inicio = time.perf_counter()

    datos = await imagen.read(config.MAX_BYTES_IMAGEN + 1)
    if len(datos) > config.MAX_BYTES_IMAGEN:
        raise HTTPException(413, {"error": "imagen_muy_grande", "detalle": "Máximo 10 MB"})
    jpeg = preparar_imagen(datos)

    llm = proveedores.get(config.PROVEEDOR_ANALISIS)
    respaldo = None if llm else "sin_api_key"
    intentos_previos = 0

    if llm and llm.nombre != "ollama":
        try:
            analisis, intentos = await analizar_con(llm, jpeg)
            return AnalisisRespuesta(
                analisis=analisis,
                humedad_preguntar_usuario=False,
                respaldo=None,
                proveedor=llm.nombre,
                modelo=llm.modelo,
                intentos=intentos,
                latencia_ms=ms_desde(inicio),
            )
        except LLMNoDisponible as e:
            respaldo = "sin_conexion"
            log.warning("Gemini no disponible, uso Ollama: %s", e)
        except LLMError as e:
            respaldo = "error_gemini"
            log.warning("Gemini falló, uso Ollama: %s", e)
        except RespuestaInvalida as e:
            respaldo = "respuesta_invalida"
            intentos_previos = MAX_INTENTOS
            log.warning("Gemini respondió inválido, uso Ollama: %s", e)

    # Respaldo local (o proveedor preferido si PROVEEDOR_ANALISIS=ollama)
    local = proveedores["ollama"]
    try:
        analisis, intentos = await analizar_con(local, jpeg)
    except (LLMNoDisponible, LLMError) as e:
        raise errores_llm(e)
    except RespuestaInvalida as e:
        raise HTTPException(
            502, {"error": "respuesta_invalida_llm", "detalle": str(e), "latencia_ms": ms_desde(inicio)}
        )

    # El modelo local no distingue tierra húmeda de seca: que la app le pregunte al campesino
    analisis.humedad_aparente = "no_determinable"
    return AnalisisRespuesta(
        analisis=analisis,
        humedad_preguntar_usuario=True,
        respaldo=respaldo,
        proveedor=local.nombre,
        modelo=local.modelo,
        intentos=intentos_previos + intentos,
        latencia_ms=ms_desde(inicio),
    )


def max_oraciones(texto: str, n: int = 3) -> str:
    oraciones = re.split(r"(?<=[.!?])\s+", " ".join(texto.split()))
    return " ".join(oraciones[:n])


@app.post("/explicar", response_model=ExplicarRespuesta)
async def explicar(entrada: ExplicarEntrada, proveedores: dict[str, Proveedor] = Depends(obtener_proveedores)):
    inicio = time.perf_counter()
    llm = proveedores.get(config.PROVEEDOR_EXPLICAR) or proveedores["ollama"]

    datos = "\n".join(
        f"- {clave}: {d.valor} (fuente: {d.fuente.upper()}, {FRASE_FUENTE[d.fuente]})"
        for clave, d in entrada.datos_regla.items()
    ) or "- (sin datos adicionales)"
    prompt = prompts.PROMPT_EXPLICAR.format(
        municipio=entrada.municipio,
        cultivo=entrada.cultivo,
        puntaje=entrada.puntaje,
        mes_actual=entrada.mes_actual or "no indicado",
        datos=datos,
        razon_siembra=frase_siembra(entrada.siembra, entrada.mes_actual) if entrada.siembra else "(no hay)",
    )
    try:
        texto = await llm.generar(prompt, sistema=prompts.SISTEMA_EXPLICAR, pensar_minimo=True)
    except (LLMNoDisponible, LLMError) as e:
        raise errores_llm(e)

    explicacion = max_oraciones(texto)
    if not explicacion:
        raise HTTPException(502, {"error": "respuesta_vacia_llm", "detalle": "El modelo no devolvió texto"})

    return ExplicarRespuesta(
        explicacion=explicacion, proveedor=llm.nombre, modelo=llm.modelo, latencia_ms=ms_desde(inicio)
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app.main:app", host="0.0.0.0", port=config.PORT)
