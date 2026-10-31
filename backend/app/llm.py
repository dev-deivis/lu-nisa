"""Capa de proveedores de LLM. Ollama (local) y Gemini comparten el mismo contrato."""

import base64
import json
import logging
import re
from typing import Protocol

import httpx

from app import config

log = logging.getLogger("lunisa.llm")


class LLMNoDisponible(Exception):
    """El proveedor no respondió (caído, sin red, timeout)."""


class LLMError(Exception):
    """El proveedor respondió con un error."""


class Proveedor(Protocol):
    nombre: str
    modelo: str

    async def generar(
        self,
        prompt: str,
        sistema: str | None = None,
        imagen: bytes | None = None,
        json_mode: bool = False,
        pensar_minimo: bool = False,
    ) -> str: ...

    async def salud(self) -> dict: ...


class OllamaProvider:
    nombre = "ollama"

    def __init__(self, host: str, modelo: str, timeout: float):
        self.host = host
        self.modelo = modelo
        self.timeout = timeout

    async def generar(self, prompt, sistema=None, imagen=None, json_mode=False, pensar_minimo=False) -> str:
        # pensar_minimo no aplica: con Ollama el razonamiento siempre va apagado (think=False)
        mensajes = []
        if sistema:
            mensajes.append({"role": "system", "content": sistema})
        usuario = {"role": "user", "content": prompt}
        if imagen:
            usuario["images"] = [base64.b64encode(imagen).decode()]
        mensajes.append(usuario)

        cuerpo = {
            "model": self.modelo,
            "messages": mensajes,
            "stream": False,
            "think": False,
            "options": {"temperature": 0},
        }
        if json_mode:
            cuerpo["format"] = "json"

        try:
            async with httpx.AsyncClient(timeout=self.timeout) as cliente:
                r = await cliente.post(f"{self.host}/api/chat", json=cuerpo)
        except (httpx.ConnectError, httpx.TimeoutException) as e:
            raise LLMNoDisponible(f"Ollama no disponible en {self.host}: {e!r}") from e

        if r.status_code != 200:
            raise LLMError(f"Ollama respondió {r.status_code}: {r.text[:300]}")
        return r.json()["message"]["content"]

    async def salud(self) -> dict:
        try:
            async with httpx.AsyncClient(timeout=5) as cliente:
                r = await cliente.get(f"{self.host}/api/tags")
            modelos = [m["name"] for m in r.json().get("models", [])]
            return {"ok": self.modelo in modelos, "modelo": self.modelo, "host": self.host}
        except Exception as e:
            return {"ok": False, "modelo": self.modelo, "host": self.host, "error": repr(e)}


class GeminiProvider:
    nombre = "gemini"

    def __init__(self, api_key: str, modelo: str, timeout: float):
        from google import genai
        from google.genai import types

        self.cliente = genai.Client(
            api_key=api_key,
            # Sin reintentos internos: si Gemini falla preferimos caer rápido a Ollama
            http_options=types.HttpOptions(
                timeout=int(timeout * 1000), retry_options=types.HttpRetryOptions(attempts=1)
            ),
        )
        self.modelo = modelo
        # Se apagan si la API las rechaza para este modelo (pasa con Gemma)
        self._usar_system = True
        self._usar_thinking = True

    async def generar(self, prompt, sistema=None, imagen=None, json_mode=False, pensar_minimo=False) -> str:
        # json_mode no se usa: Gemma en la API de Gemini no soporta response_mime_type,
        # el JSON se extrae del texto con extraer_json()
        from google.genai import errors, types

        partes = []
        if imagen:
            partes.append(types.Part.from_bytes(data=imagen, mime_type="image/jpeg"))

        # Hasta 3 intentos: se va apagando la opción que la API rechace
        for _ in range(3):
            usar_system = bool(sistema) and self._usar_system
            usar_thinking = pensar_minimo and self._usar_thinking
            texto = prompt if usar_system or not sistema else f"{sistema}\n\n{prompt}"
            try:
                return await self._llamar(
                    partes + [texto],
                    types.GenerateContentConfig(
                        system_instruction=sistema if usar_system else None,
                        thinking_config=types.ThinkingConfig(thinking_level="minimal") if usar_thinking else None,
                        temperature=0,
                    ),
                )
            except errors.ClientError as e:
                msg = str(e).lower()
                if e.code == 400 and usar_thinking and "think" in msg:
                    log.warning("Gemini rechazó thinking_level para %s; sigo sin él", self.modelo)
                    self._usar_thinking = False
                elif e.code == 400 and usar_system and "instruction" in msg:
                    log.warning("Gemini rechazó system_instruction para %s; uso un solo mensaje", self.modelo)
                    self._usar_system = False
                else:
                    raise LLMError(f"Gemini respondió error: {e}") from e
            except errors.APIError as e:
                raise LLMError(f"Gemini respondió error: {e}") from e
        raise LLMError("Gemini rechazó la petición con todas las configuraciones")

    async def _llamar(self, contenido, cfg) -> str:
        try:
            resp = await self.cliente.aio.models.generate_content(model=self.modelo, contents=contenido, config=cfg)
        except (httpx.HTTPError, OSError, TimeoutError) as e:
            raise LLMNoDisponible(f"Gemini no disponible: {e!r}") from e
        return resp.text or ""

    async def salud(self) -> dict:
        return {
            "ok": True,
            "modelo": self.modelo,
            "system_instruction": self._usar_system,
            "thinking_minimo": self._usar_thinking,
        }


def extraer_json(texto: str) -> dict:
    """Saca el objeto JSON de la respuesta, tolerando bloques ```json ... ```."""
    limpio = re.sub(r"^```(?:json)?\s*|\s*```$", "", texto.strip())
    inicio, fin = limpio.find("{"), limpio.rfind("}")
    if inicio == -1 or fin == -1:
        raise ValueError(f"No hay un objeto JSON en la respuesta: {texto[:200]!r}")
    return json.loads(limpio[inicio : fin + 1])


def crear_proveedores() -> dict[str, Proveedor]:
    """Ollama siempre está (es el respaldo sin internet); Gemini solo si hay API key."""
    proveedores: dict[str, Proveedor] = {
        "ollama": OllamaProvider(config.OLLAMA_HOST, config.OLLAMA_MODEL, config.OLLAMA_TIMEOUT)
    }
    if config.GEMINI_API_KEY:
        proveedores["gemini"] = GeminiProvider(config.GEMINI_API_KEY, config.GEMINI_MODEL, config.GEMINI_TIMEOUT)

    for tarea, nombre in [("PROVEEDOR_ANALISIS", config.PROVEEDOR_ANALISIS), ("PROVEEDOR_EXPLICAR", config.PROVEEDOR_EXPLICAR)]:
        if nombre not in ("ollama", "gemini"):
            raise RuntimeError(f"{tarea} inválido: {nombre!r} (usa ollama o gemini)")
        if nombre not in proveedores:
            log.warning("%s=%s pero falta GEMINI_API_KEY; esa tarea usará Ollama", tarea, nombre)
    return proveedores
