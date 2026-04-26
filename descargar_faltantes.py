import urllib.request
import json
import csv
import time
import os

faltantes = [
    {"nombre": "San Lucas Camotlán", "lat": 17.0333, "lon": -96.0167, "distrito": "Mixe", "altitud": 950},
    {"nombre": "San Miguel Yotao", "lat": 17.0833, "lon": -96.1833, "distrito": "Mixe", "altitud": 1600},
    {"nombre": "Tabaá", "lat": 17.2000, "lon": -96.1833, "distrito": "Villa Alta", "altitud": 1400},
    {"nombre": "San Pedro y San Pablo Teposcolula", "lat": 17.2333, "lon": -96.1500, "distrito": "Villa Alta", "altitud": 1400},
    {"nombre": "San Pedro y San Pablo Tlistac", "lat": 17.2000, "lon": -96.1667, "distrito": "Villa Alta", "altitud": 1350},
    {"nombre": "Santo Domingo Roayaga", "lat": 17.1700, "lon": -96.1900, "distrito": "Villa Alta", "altitud": 1300},
    {"nombre": "Cacalotepec", "lat": 17.0333, "lon": -96.1500, "distrito": "Mixe", "altitud": 1700},
    {"nombre": "El Espinal", "lat": 17.0500, "lon": -96.1500, "distrito": "Mixe", "altitud": 1500},
    {"nombre": "Quetzaltepec", "lat": 17.0167, "lon": -96.0500, "distrito": "Mixe", "altitud": 1100},
]

resultados = []

for i, m in enumerate(faltantes):
    url = (
        f"https://historical-forecast-api.open-meteo.com/v1/forecast?"
        f"latitude={m['lat']}&longitude={m['lon']}"
        f"&start_date=2018-01-01&end_date=2023-12-31"
        f"&daily=temperature_2m_max,temperature_2m_min,temperature_2m_mean,"
        f"precipitation_sum,relative_humidity_2m_mean,et0_fao_evapotranspiration"
        f"&timezone=America%2FMexico_City"
    )

    exito = False
    intentos = 0
    while not exito and intentos < 5:
        try:
            print(f"[{i+1}/{len(faltantes)}] {m['nombre']}...", end=" ", flush=True)
            with urllib.request.urlopen(url, timeout=30) as resp:
                data = json.loads(resp.read())
            daily = data.get("daily", {})
            dates = daily.get("time", [])
            for j, fecha in enumerate(dates):
                resultados.append({
                    "municipio": m["nombre"],
                    "distrito": m["distrito"],
                    "altitud": m["altitud"],
                    "lat": m["lat"],
                    "lon": m["lon"],
                    "fecha": fecha,
                    "mes": int(fecha.split("-")[1]),
                    "temp_max": daily.get("temperature_2m_max", [None]*len(dates))[j],
                    "temp_min": daily.get("temperature_2m_min", [None]*len(dates))[j],
                    "temp_media": daily.get("temperature_2m_mean", [None]*len(dates))[j],
                    "precipitacion_mm": daily.get("precipitation_sum", [None]*len(dates))[j],
                    "humedad": daily.get("relative_humidity_2m_mean", [None]*len(dates))[j],
                    "evapotranspiracion": daily.get("et0_fao_evapotranspiration", [None]*len(dates))[j],
                })
            print(f"✅ {len(dates)} días")
            exito = True
            time.sleep(5)
        except Exception as e:
            intentos += 1
            print(f"⏳ reintentando ({intentos}/5)... {e}")
            time.sleep(15 * intentos)

if resultados:
    with open("data/clima/historico_sierra_norte.csv", "a", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=resultados[0].keys())
        writer.writerows(resultados)
    print(f"\n✅ {len(resultados)} filas agregadas")
