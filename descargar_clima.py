import urllib.request
import json
import csv
import time
import os

municipios = [
    {"nombre": "Abejones", "lat": 17.2833, "lon": -96.5167, "distrito": "Ixtlán", "altitud": 2200},
    {"nombre": "Capulálpam de Méndez", "lat": 17.3167, "lon": -96.4667, "distrito": "Ixtlán", "altitud": 2000},
    {"nombre": "Guelatao de Juárez", "lat": 17.3167, "lon": -96.4833, "distrito": "Ixtlán", "altitud": 1750},
    {"nombre": "Ixtlán de Juárez", "lat": 17.3333, "lon": -96.4833, "distrito": "Ixtlán", "altitud": 1950},
    {"nombre": "Natividad", "lat": 17.3000, "lon": -96.4500, "distrito": "Ixtlán", "altitud": 1800},
    {"nombre": "San Juan Chicomezúchil", "lat": 17.2667, "lon": -96.5000, "distrito": "Ixtlán", "altitud": 2100},
    {"nombre": "San Juan Evangelista Analco", "lat": 17.2500, "lon": -96.4333, "distrito": "Ixtlán", "altitud": 1900},
    {"nombre": "San Miguel Amatlán", "lat": 17.3500, "lon": -96.5333, "distrito": "Ixtlán", "altitud": 2300},
    {"nombre": "San Miguel del Río", "lat": 17.3000, "lon": -96.5500, "distrito": "Ixtlán", "altitud": 1600},
    {"nombre": "San Pablo Macuiltianguis", "lat": 17.4167, "lon": -96.5000, "distrito": "Ixtlán", "altitud": 1700},
    {"nombre": "San Pedro Yaneri", "lat": 17.3833, "lon": -96.3833, "distrito": "Ixtlán", "altitud": 1400},
    {"nombre": "San Pedro Yólox", "lat": 17.4500, "lon": -96.4667, "distrito": "Ixtlán", "altitud": 1500},
    {"nombre": "Santa Catarina Ixtepeji", "lat": 17.2167, "lon": -96.5500, "distrito": "Ixtlán", "altitud": 2400},
    {"nombre": "Santiago Comaltepec", "lat": 17.4833, "lon": -96.5167, "distrito": "Ixtlán", "altitud": 1300},
    {"nombre": "Santiago Xiacuí", "lat": 17.3000, "lon": -96.4667, "distrito": "Ixtlán", "altitud": 1850},
    {"nombre": "Santo Tomás Mazaltepec", "lat": 17.2000, "lon": -96.6000, "distrito": "Ixtlán", "altitud": 2100},
    {"nombre": "San Andrés Solaga", "lat": 17.2000, "lon": -96.2833, "distrito": "Villa Alta", "altitud": 1800},
    {"nombre": "San Andrés Yaa", "lat": 17.1833, "lon": -96.2167, "distrito": "Villa Alta", "altitud": 1600},
    {"nombre": "San Baltazar Yatzachi el Bajo", "lat": 17.1667, "lon": -96.2500, "distrito": "Villa Alta", "altitud": 1700},
    {"nombre": "San Cristóbal Lachirioag", "lat": 17.1500, "lon": -96.1833, "distrito": "Villa Alta", "altitud": 1500},
    {"nombre": "San Francisco Cajonos", "lat": 17.1333, "lon": -96.2000, "distrito": "Villa Alta", "altitud": 1650},
    {"nombre": "San Francisco Yatzachi el Alto", "lat": 17.1833, "lon": -96.2667, "distrito": "Villa Alta", "altitud": 1900},
    {"nombre": "San Ildefonso Villa Alta", "lat": 17.1667, "lon": -96.1500, "distrito": "Villa Alta", "altitud": 1200},
    {"nombre": "San Juan Tabaá", "lat": 17.2167, "lon": -96.2000, "distrito": "Villa Alta", "altitud": 1550},
    {"nombre": "San Juan Yaeé", "lat": 17.2000, "lon": -96.2500, "distrito": "Villa Alta", "altitud": 1700},
    {"nombre": "San Juan Yatzona", "lat": 17.1500, "lon": -96.2333, "distrito": "Villa Alta", "altitud": 1400},
    {"nombre": "San Melchor Betaza", "lat": 17.1833, "lon": -96.2333, "distrito": "Villa Alta", "altitud": 1750},
    {"nombre": "San Miguel Amatitlán", "lat": 17.2333, "lon": -96.1833, "distrito": "Villa Alta", "altitud": 1300},
    {"nombre": "San Miguel Quetzaltepec", "lat": 17.0333, "lon": -96.0000, "distrito": "Villa Alta", "altitud": 1000},
    {"nombre": "San Pablo Yaganiza", "lat": 17.1667, "lon": -96.2167, "distrito": "Villa Alta", "altitud": 1600},
    {"nombre": "San Pedro Cajonos", "lat": 17.1333, "lon": -96.2167, "distrito": "Villa Alta", "altitud": 1500},
    {"nombre": "San Pedro Ocotepec", "lat": 17.0500, "lon": -96.0500, "distrito": "Villa Alta", "altitud": 900},
    {"nombre": "San Pedro y San Pablo Ayutla", "lat": 17.1000, "lon": -96.1167, "distrito": "Villa Alta", "altitud": 1100},
    {"nombre": "Santa María Temaxcalapa", "lat": 17.1167, "lon": -96.0833, "distrito": "Villa Alta", "altitud": 1000},
    {"nombre": "Santa María Yalina", "lat": 17.2500, "lon": -96.2333, "distrito": "Villa Alta", "altitud": 1600},
    {"nombre": "Santiago Camotlán", "lat": 17.0667, "lon": -96.0333, "distrito": "Villa Alta", "altitud": 850},
    {"nombre": "Santiago Choápam", "lat": 17.3333, "lon": -96.1667, "distrito": "Villa Alta", "altitud": 800},
    {"nombre": "Santiago Lalopa", "lat": 17.1500, "lon": -96.2667, "distrito": "Villa Alta", "altitud": 1650},
    {"nombre": "Santiago Laxopa", "lat": 17.2167, "lon": -96.2833, "distrito": "Villa Alta", "altitud": 1800},
    {"nombre": "Santiago Zoochila", "lat": 17.2000, "lon": -96.3000, "distrito": "Villa Alta", "altitud": 1900},
    {"nombre": "Santo Domingo Roayaga", "lat": 17.1667, "lon": -96.1833, "distrito": "Villa Alta", "altitud": 1300},
    {"nombre": "Santo Domingo Xagacía", "lat": 17.2333, "lon": -96.2667, "distrito": "Villa Alta", "altitud": 1700},
    {"nombre": "Talea de Castro", "lat": 17.2000, "lon": -96.2167, "distrito": "Villa Alta", "altitud": 1500},
    {"nombre": "Tamazulapam del Espíritu Santo", "lat": 17.2667, "lon": -96.2333, "distrito": "Villa Alta", "altitud": 1750},
    {"nombre": "Zoogocho", "lat": 17.1833, "lon": -96.2833, "distrito": "Villa Alta", "altitud": 1850},
    {"nombre": "Alotepec", "lat": 17.0000, "lon": -96.1000, "distrito": "Mixe", "altitud": 2200},
    {"nombre": "Asunción Cacalotepec", "lat": 17.0167, "lon": -96.1667, "distrito": "Mixe", "altitud": 1800},
    {"nombre": "Ayutla Mixe", "lat": 17.0833, "lon": -96.1167, "distrito": "Mixe", "altitud": 1200},
    {"nombre": "Cotzocón", "lat": 17.3500, "lon": -95.8000, "distrito": "Mixe", "altitud": 400},
    {"nombre": "Dolores Hidalgo Mixe", "lat": 16.9833, "lon": -96.0167, "distrito": "Mixe", "altitud": 900},
    {"nombre": "Mixistlán de la Reforma", "lat": 17.0500, "lon": -96.2000, "distrito": "Mixe", "altitud": 2600},
    {"nombre": "Ocotepec", "lat": 17.0167, "lon": -96.0833, "distrito": "Mixe", "altitud": 1000},
    {"nombre": "San Juan Cotzocón", "lat": 17.2500, "lon": -95.8833, "distrito": "Mixe", "altitud": 350},
    {"nombre": "San Juan Guichicovi", "lat": 16.9667, "lon": -95.1000, "distrito": "Mixe", "altitud": 150},
    {"nombre": "San Lucas Camotlán", "lat": 17.0333, "lon": -96.0167, "distrito": "Mixe", "altitud": 950},
    {"nombre": "San Miguel Yotao", "lat": 17.0833, "lon": -96.1833, "distrito": "Mixe", "altitud": 1600},
    {"nombre": "Santa María Alotepec", "lat": 17.0167, "lon": -96.1333, "distrito": "Mixe", "altitud": 2000},
    {"nombre": "Santiago Atitlán", "lat": 17.0667, "lon": -96.1333, "distrito": "Mixe", "altitud": 1400},
    {"nombre": "Santiago Zacatepec", "lat": 17.0000, "lon": -96.1667, "distrito": "Mixe", "altitud": 2400},
    {"nombre": "Tepantlali", "lat": 17.1333, "lon": -96.0167, "distrito": "Mixe", "altitud": 700},
    {"nombre": "Totontepec Villa de Morelos", "lat": 17.0333, "lon": -96.1833, "distrito": "Mixe", "altitud": 2000},
]

os.makedirs("data/clima", exist_ok=True)

resultados = []

for i, m in enumerate(municipios):
    nombre_safe = m["nombre"].replace(" ", "_").replace("/", "-")
    url = (
        f"https://historical-forecast-api.open-meteo.com/v1/forecast?"
        f"latitude={m['lat']}&longitude={m['lon']}"
        f"&start_date=2018-01-01&end_date=2023-12-31"
        f"&daily=temperature_2m_max,temperature_2m_min,temperature_2m_mean,"
        f"precipitation_sum,relative_humidity_2m_mean,et0_fao_evapotranspiration"
        f"&timezone=America%2FMexico_City"
    )
    
    try:
        print(f"[{i+1}/68] {m['nombre']}...", end=" ")
        with urllib.request.urlopen(url, timeout=30) as resp:
            data = json.loads(resp.read())
        
        daily = data.get("daily", {})
        dates = daily.get("time", [])
        
        for j, fecha in enumerate(dates):
            mes = int(fecha.split("-")[1])
            resultados.append({
                "municipio": m["nombre"],
                "distrito": m["distrito"],
                "altitud": m["altitud"],
                "lat": m["lat"],
                "lon": m["lon"],
                "fecha": fecha,
                "mes": mes,
                "temp_max": daily.get("temperature_2m_max", [None]*len(dates))[j],
                "temp_min": daily.get("temperature_2m_min", [None]*len(dates))[j],
                "temp_media": daily.get("temperature_2m_mean", [None]*len(dates))[j],
                "precipitacion_mm": daily.get("precipitation_sum", [None]*len(dates))[j],
                "humedad": daily.get("relative_humidity_2m_mean", [None]*len(dates))[j],
                "evapotranspiracion": daily.get("et0_fao_evapotranspiration", [None]*len(dates))[j],
            })
        print(f"✅ {len(dates)} días")
        time.sleep(0.5)  # respetar rate limit
        
    except Exception as e:
        print(f"❌ Error: {e}")

# Guardar CSV
if resultados:
    keys = resultados[0].keys()
    with open("data/clima/historico_sierra_norte.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=keys)
        writer.writeheader()
        writer.writerows(resultados)
    print(f"\n✅ CSV guardado: data/clima/historico_sierra_norte.csv")
    print(f"   Total filas: {len(resultados)}")
else:
    print("\n❌ No se obtuvieron datos")
