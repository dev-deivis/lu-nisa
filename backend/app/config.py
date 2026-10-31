import os
from pathlib import Path

from dotenv import load_dotenv

# Carga backend/.env sin importar desde dónde se arranque uvicorn
load_dotenv(Path(__file__).resolve().parent.parent / ".env")

# Proveedor preferido por tarea: ollama | gemini
PROVEEDOR_ANALISIS = os.getenv("PROVEEDOR_ANALISIS", "gemini").strip().lower()
PROVEEDOR_EXPLICAR = os.getenv("PROVEEDOR_EXPLICAR", "ollama").strip().lower()

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434").rstrip("/")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "gemma4:e4b")
OLLAMA_TIMEOUT = float(os.getenv("OLLAMA_TIMEOUT", "120"))

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "").strip()
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemma-4-26b-a4b-it")
# Corto para que Gemini + respaldo en Ollama quepan en los 90 s de la app
GEMINI_TIMEOUT = float(os.getenv("GEMINI_TIMEOUT", "30"))

PORT = int(os.getenv("PORT", "8000"))

# Límites de la imagen recibida
MAX_BYTES_IMAGEN = 10 * 1024 * 1024
LADO_MAX_IMAGEN = 1024
