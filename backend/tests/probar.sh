#!/usr/bin/env bash
# Prueba manual con curl contra el servidor corriendo.
# Uso: ./tests/probar.sh [URL]   (default http://localhost:8000)
set -u
URL="${1:-http://localhost:8000}"
SAMPLES="$(dirname "$0")/../samples"

echo "== GET /salud"
curl -s "$URL/salud" | python3 -m json.tool
echo

for foto in seca_desnuda humeda_desnuda milpa mucho_cielo no_parcela; do
  archivo="$SAMPLES/$foto.jpg"
  if [ ! -f "$archivo" ]; then
    echo "== $foto.jpg: no existe, se salta"
    continue
  fi
  echo "== POST /analizar-parcela  $foto.jpg"
  curl -s -F "imagen=@$archivo;type=image/jpeg" "$URL/analizar-parcela" | python3 -m json.tool
  echo
done

echo "== POST /explicar"
curl -s -H "Content-Type: application/json" "$URL/explicar" -d '{
  "municipio": "Ixtlán de Juárez",
  "cultivo": "Maíz",
  "puntaje": 85,
  "datos_regla": {
    "humedad": {"valor": "húmeda", "fuente": "foto"},
    "lluvia_reciente": {"valor": "sí", "fuente": "campesino"},
    "mes": {"valor": "junio", "fuente": "datos"}
  }
}' | python3 -m json.tool
