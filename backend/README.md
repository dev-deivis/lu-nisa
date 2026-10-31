# Lu-nisa backend

FastAPI + Gemma 4 (Ollama local o API de Gemini) para analizar fotos de parcelas
y explicar recomendaciones de cultivo.

## Arrancar

```bash
cd backend
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
cp .env.example .env          # pon tu GEMINI_API_KEY
ollama pull gemma4:e4b        # respaldo local y /explicar
.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000
```

## Proveedores por tarea

| Tarea | Preferido | Respaldo |
|---|---|---|
| `/analizar-parcela` | Gemini `gemma-4-26b-a4b-it` (`PROVEEDOR_ANALISIS`) | Ollama `gemma4:e4b` si Gemini falla, no hay red o no hay API key. En ese caso `humedad_aparente="no_determinable"` y `humedad_preguntar_usuario=true` (e4b no distingue húmeda de seca) |
| `/explicar` | Ollama (`PROVEEDOR_EXPLICAR`, funciona sin internet) | Si `PROVEEDOR_EXPLICAR=gemini` y Gemini falla, no hay red o no hay API key, cae a Ollama |

## Endpoints

| Ruta | Entrada | Salida |
|---|---|---|
| `GET /salud` | — | proveedor activo y si el modelo responde |
| `POST /analizar-parcela` | multipart `imagen` (jpeg/png/webp, ≤10 MB) | `{analisis, humedad_preguntar_usuario, respaldo, proveedor, modelo, intentos, latencia_ms}` |
| `POST /explicar` | `{municipio, cultivo, puntaje, datos_regla: {clave: {valor, fuente: foto\|campesino\|datos}}}` | `{explicacion, respaldo, proveedor, modelo, latencia_ms}` |

`analisis` solo trae atributos observables (`es_parcela`, `suelo_desnudo`, `humedad_aparente`,
`pendiente`, `piedras`, `cobertura_vegetal`, `confianza`, `observaciones`). Nunca fertilidad, nutrientes ni pH.
`confianza` es informativo: ninguna lógica lo usa.

Errores: `415` imagen inválida · `413` muy grande · `502` el modelo respondió mal dos veces · `503` Ollama/Gemini no disponible.

## Pruebas

```bash
.venv/bin/python -m pytest -m "not integracion"   # unitarias, sin LLM
.venv/bin/python -m pytest -m integracion -s      # con el servidor corriendo + fotos en samples/
./tests/probar.sh                                  # lo mismo con curl
```

Fotos esperadas en `samples/`: `seca_desnuda.jpg`, `humeda_desnuda.jpg`, `milpa.jpg`, `mucho_cielo.jpg`, `no_parcela.jpg`.

## Limitaciones conocidas

- **Rangos de lluvia del CSV** (`assets/data/cultivos_sierra_norte.csv`): las columnas `precipitacion_min_mm` y `precipitacion_max_mm` mezclan criterios. En algunos cultivos parecen ser la lluvia del ciclo (de la siembra a la cosecha) y en otros la lluvia anual de la zona donde se siembran. Por eso el puntaje base de `generar_recomendaciones.py` todavía no compara la lluvia de forma consistente. Los rangos deben validarse con un agrónomo o con una fuente oficial (SIAP/INIFAP) antes de usar los puntajes como recomendación real.
