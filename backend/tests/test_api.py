"""
Pruebas del backend.

- Unitarias: usan un proveedor falso, no necesitan Ollama.
      .venv/bin/python -m pytest -m "not integracion"
- Integración: pegan al servidor real (LUNISA_URL, default http://localhost:8000)
  con las fotos de samples/. Se saltan si el servidor no responde.
      .venv/bin/python -m pytest -m integracion -s
"""

import io
import json
import os
from pathlib import Path

import httpx
import pytest
from fastapi.testclient import TestClient
from PIL import Image

from app import config
from app.llm import LLMError, LLMNoDisponible
from app.main import app, obtener_proveedores

SAMPLES = Path(__file__).resolve().parent.parent / "samples"
FOTOS = ["seca_desnuda.jpg", "humeda_desnuda.jpg", "milpa.jpg", "mucho_cielo.jpg", "no_parcela.jpg"]
URL = os.getenv("LUNISA_URL", "http://localhost:8000")

VALIDO = {
    "es_parcela": True,
    "suelo_desnudo": "no_determinable",
    "humedad_aparente": "humeda",
    "pendiente": "moderada",
    "piedras": "pocas",
    "cobertura_vegetal": "parcial",
    "confianza": "media",
    "observaciones": " ".join(["palabra"] * 40),
}


def jpeg_falso(ancho=2000, alto=1500) -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", (ancho, alto), (120, 80, 40)).save(buf, format="JPEG")
    return buf.getvalue()


class ProveedorFalso:
    def __init__(self, nombre, respuestas):
        self.nombre = nombre
        self.modelo = f"{nombre}-falso"
        self.respuestas = list(respuestas)
        self.llamadas = []

    async def generar(self, prompt, sistema=None, imagen=None, json_mode=False, pensar_minimo=False):
        self.llamadas.append({"prompt": prompt, "imagen": imagen, "pensar_minimo": pensar_minimo})
        r = self.respuestas.pop(0)
        if isinstance(r, Exception):
            raise r
        return r

    async def salud(self):
        return {"ok": True}


@pytest.fixture
def cliente_con(monkeypatch):
    """Crea un TestClient con proveedores falsos: cliente_con(gemini=[...], ollama=[...])."""

    def _crear(gemini=None, ollama=(), analisis="gemini", explicar="ollama"):
        monkeypatch.setattr(config, "PROVEEDOR_ANALISIS", analisis)
        monkeypatch.setattr(config, "PROVEEDOR_EXPLICAR", explicar)
        provs = {"ollama": ProveedorFalso("ollama", ollama)}
        if gemini is not None:
            provs["gemini"] = ProveedorFalso("gemini", gemini)
        app.dependency_overrides[obtener_proveedores] = lambda: provs
        return TestClient(app), provs

    yield _crear
    app.dependency_overrides.clear()


def subir(cliente, datos=None):
    return cliente.post("/analizar-parcela", files={"imagen": ("a.jpg", datos or jpeg_falso(), "image/jpeg")})


# ── Unitarias ────────────────────────────────────────────────────────────────


def test_gemini_valido_recorta_observaciones_y_reduce_imagen(cliente_con):
    cliente, provs = cliente_con(gemini=[json.dumps(VALIDO)])
    r = subir(cliente)

    assert r.status_code == 200, r.text
    cuerpo = r.json()
    assert cuerpo["proveedor"] == "gemini" and cuerpo["respaldo"] is None
    assert cuerpo["humedad_preguntar_usuario"] is False
    assert cuerpo["analisis"]["humedad_aparente"] == "humeda"
    assert cuerpo["analisis"]["suelo_desnudo"] == "no_determinable"
    assert len(cuerpo["analisis"]["observaciones"].split()) == 25
    assert isinstance(cuerpo["latencia_ms"], int)
    assert max(Image.open(io.BytesIO(provs["gemini"].llamadas[0]["imagen"])).size) == 1024
    assert provs["ollama"].llamadas == []


def test_gemini_reintenta_una_vez_con_el_error(cliente_con):
    cliente, provs = cliente_con(gemini=["esto no es json", "```json\n" + json.dumps(VALIDO) + "\n```"])
    r = subir(cliente)

    assert r.status_code == 200, r.text
    assert r.json()["intentos"] == 2 and r.json()["proveedor"] == "gemini"
    assert "no fue válida" in provs["gemini"].llamadas[1]["prompt"]


@pytest.mark.parametrize(
    "falla, respaldo",
    [
        ([LLMNoDisponible("sin red")], "sin_conexion"),
        ([LLMError("429 cuota")], "error_gemini"),
        (["{}", "{}"], "respuesta_invalida"),
    ],
)
def test_respaldo_ollama_pide_humedad_al_usuario(cliente_con, falla, respaldo):
    cliente, provs = cliente_con(gemini=falla, ollama=[json.dumps(VALIDO)])
    r = subir(cliente)

    assert r.status_code == 200, r.text
    cuerpo = r.json()
    assert cuerpo["proveedor"] == "ollama" and cuerpo["respaldo"] == respaldo
    assert cuerpo["humedad_preguntar_usuario"] is True
    assert cuerpo["analisis"]["humedad_aparente"] == "no_determinable"


def test_sin_api_key_usa_ollama(cliente_con):
    cliente, _ = cliente_con(gemini=None, ollama=[json.dumps(VALIDO)])
    r = subir(cliente)

    assert r.status_code == 200, r.text
    assert r.json()["respaldo"] == "sin_api_key" and r.json()["humedad_preguntar_usuario"] is True


def test_502_si_tambien_ollama_responde_invalido(cliente_con):
    malo = json.dumps({**VALIDO, "pendiente": "empinadisima", "fertilidad": "alta"})
    cliente, provs = cliente_con(gemini=[malo, malo], ollama=[malo, malo])
    r = subir(cliente)

    assert r.status_code == 502
    assert r.json()["detail"]["error"] == "respuesta_invalida_llm"
    assert len(provs["gemini"].llamadas) == 2 and len(provs["ollama"].llamadas) == 2


def test_503_si_nadie_responde(cliente_con):
    cliente, _ = cliente_con(gemini=[LLMNoDisponible("x")], ollama=[LLMNoDisponible("y")])
    assert subir(cliente).status_code == 503


def test_rechaza_archivo_que_no_es_imagen(cliente_con):
    cliente, provs = cliente_con(gemini=[])
    r = subir(cliente, b"hola")

    assert r.status_code == 415
    assert provs["gemini"].llamadas == []


def test_explicar_usa_ollama_con_fuentes_y_max_tres_oraciones(cliente_con):
    cliente, provs = cliente_con(gemini=[], ollama=["Una. Dos! Tres? Cuatro. Cinco."])
    r = cliente.post(
        "/explicar",
        json={
            "municipio": "Ixtlán de Juárez",
            "cultivo": "Maíz",
            "puntaje": 85,
            "datos_regla": {
                "humedad": {"valor": "húmeda", "fuente": "foto"},
                "lluvia_reciente": {"valor": "sí", "fuente": "campesino"},
            },
        },
    )

    assert r.status_code == 200, r.text
    assert r.json()["explicacion"] == "Una. Dos! Tres?"
    assert r.json()["proveedor"] == "ollama"
    prompt = provs["ollama"].llamadas[0]["prompt"]
    assert "fuente: FOTO" in prompt and "fuente: CAMPESINO" in prompt
    assert provs["ollama"].llamadas[0]["pensar_minimo"] is False  # solo aplica a Gemini


def test_explicar_rechaza_fuente_desconocida(cliente_con):
    cliente, _ = cliente_con()
    r = cliente.post(
        "/explicar",
        json={"municipio": "X", "cultivo": "Maíz", "puntaje": 50, "datos_regla": {"a": {"valor": 1, "fuente": "tele"}}},
    )
    assert r.status_code == 422


# ── Integración (servidor real) ──────────────────────────────────────────────


def _servidor_arriba() -> bool:
    try:
        return httpx.get(f"{URL}/salud", timeout=3).status_code == 200
    except httpx.HTTPError:
        return False


integracion = pytest.mark.skipif(not _servidor_arriba(), reason=f"servidor no responde en {URL}")


@pytest.mark.integracion
@integracion
@pytest.mark.parametrize("foto", FOTOS)
def test_real_analizar_fotos(foto):
    ruta = SAMPLES / foto
    if not ruta.exists():
        pytest.skip(f"falta samples/{foto}")

    with ruta.open("rb") as f:
        r = httpx.post(f"{URL}/analizar-parcela", files={"imagen": (foto, f, "image/jpeg")}, timeout=300)

    assert r.status_code == 200, r.text
    cuerpo = r.json()
    print(f"\n{foto}: {cuerpo['proveedor']} {cuerpo['latencia_ms']} ms, intentos={cuerpo['intentos']}, "
          f"preguntar={cuerpo['humedad_preguntar_usuario']}\n"
          f"{json.dumps(cuerpo['analisis'], ensure_ascii=False, indent=2)}")
    texto = json.dumps(cuerpo["analisis"], ensure_ascii=False).lower()
    assert "fertil" not in texto and "nutriente" not in texto and " ph" not in texto


@pytest.mark.integracion
@integracion
def test_real_explicar():
    r = httpx.post(
        f"{URL}/explicar",
        json={
            "municipio": "Ixtlán de Juárez",
            "cultivo": "Maíz",
            "puntaje": 85,
            "datos_regla": {
                "humedad": {"valor": "húmeda", "fuente": "foto"},
                "mes": {"valor": "junio", "fuente": "datos"},
            },
        },
        timeout=300,
    )

    assert r.status_code == 200, r.text
    print(f"\n{r.json()['latencia_ms']} ms: {r.json()['explicacion']}")
    assert len([o for o in r.json()["explicacion"].split(". ") if o]) <= 3


# ── Razón de siembra (sin LLM) ──────────────────────────────────────────────

from app.razones import frase_siembra  # noqa: E402
from app.schemas import Siembra  # noqa: E402


def test_frase_siembra_fuera_de_temporada_compara_lluvia():
    s = Siembra(meses="Junio-Julio", se_siembra_este_mes=False, lluvia_meses_siembra_mm=138, lluvia_mes_actual_mm=20)
    assert frase_siembra(s, "enero") == (
        "conviene sembrarlo en junio-julio, porque en esos meses suelen llover 138 mm al mes, más que los 20 mm de enero"
    )


def test_frase_siembra_cultivo_de_poca_agua_en_secas():
    s = Siembra(
        meses="Noviembre-Diciembre",
        se_siembra_este_mes=False,
        lluvia_meses_siembra_mm=32,
        lluvia_mes_actual_mm=141,
        agua_cultivo="bajo",
    )
    assert frase_siembra(s, "octubre") == (
        "conviene sembrarlo en noviembre-diciembre, porque en esos meses llueve poco (unos 32 mm al mes), "
        "menos que los 141 mm de octubre, y este cultivo necesita poca agua"
    )


def test_frase_siembra_este_mes():
    s = Siembra(meses="Octubre-Enero", se_siembra_este_mes=True, lluvia_mes_actual_mm=141)
    assert frase_siembra(s, "octubre") == (
        "ahora es buen momento para sembrarlo: se siembra en octubre-enero y en octubre suelen llover 141 mm"
    )


def test_explicar_pasa_la_razon_armada_al_prompt(cliente_con):
    cliente, provs = cliente_con(ollama=["Siémbralo en junio-julio."])
    r = cliente.post(
        "/explicar",
        json={
            "municipio": "X",
            "cultivo": "Frijol",
            "puntaje": 75,
            "mes_actual": "enero",
            "siembra": {"meses": "Junio-Julio", "se_siembra_este_mes": False, "lluvia_meses_siembra_mm": 138},
        },
    )
    assert r.status_code == 200, r.text
    assert "suelen llover 138 mm al mes" in provs["ollama"].llamadas[0]["prompt"]


# ── Respaldo de /explicar ────────────────────────────────────────────────────

EXPLICAR = {"municipio": "X", "cultivo": "Maíz", "puntaje": 80}


@pytest.mark.parametrize(
    "falla, respaldo",
    [
        ([LLMNoDisponible("sin red")], "sin_conexion"),
        ([LLMError("500")], "error_gemini"),
        (["   "], "respuesta_invalida"),
    ],
)
def test_explicar_gemini_cae_a_ollama(cliente_con, falla, respaldo):
    cliente, provs = cliente_con(gemini=falla, ollama=["Texto local."], explicar="gemini")
    r = cliente.post("/explicar", json=EXPLICAR)

    assert r.status_code == 200, r.text
    assert r.json()["proveedor"] == "ollama" and r.json()["respaldo"] == respaldo
    assert r.json()["explicacion"] == "Texto local."


def test_explicar_con_gemini_sin_respaldo(cliente_con):
    cliente, provs = cliente_con(gemini=["Texto de Gemini."], explicar="gemini")
    r = cliente.post("/explicar", json=EXPLICAR)

    assert r.json()["proveedor"] == "gemini" and r.json()["respaldo"] is None
    assert provs["gemini"].llamadas[0]["pensar_minimo"] is True
    assert provs["ollama"].llamadas == []


def test_explicar_gemini_sin_api_key_usa_ollama(cliente_con):
    cliente, _ = cliente_con(gemini=None, ollama=["Texto local."], explicar="gemini")
    r = cliente.post("/explicar", json=EXPLICAR)

    assert r.json()["proveedor"] == "ollama" and r.json()["respaldo"] == "sin_api_key"


def test_explicar_503_si_nadie_responde(cliente_con):
    cliente, _ = cliente_con(gemini=[LLMNoDisponible("x")], ollama=[LLMNoDisponible("y")], explicar="gemini")
    assert cliente.post("/explicar", json=EXPLICAR).status_code == 503
