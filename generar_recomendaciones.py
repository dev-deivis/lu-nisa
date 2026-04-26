import csv
import json
from collections import defaultdict

# 1. Cargar clima — promedios mensuales por municipio
print("Cargando datos climáticos...")
clima = defaultdict(lambda: defaultdict(list))

with open("assets/data/historico_sierra_norte.csv", encoding="utf-8") as f:
    for row in csv.DictReader(f):
        municipio = row["municipio"]
        mes = int(row["mes"])
        clima[municipio][mes].append({
            "temp_max": float(row["temp_max"] or 0),
            "temp_min": float(row["temp_min"] or 0),
            "temp_media": float(row["temp_media"] or 0),
            "precipitacion": float(row["precipitacion_mm"] or 0),
            "humedad": float(row["humedad"] or 0),
        })

# Promediar por mes
clima_promedio = {}
for municipio, meses in clima.items():
    clima_promedio[municipio] = {}
    for mes, dias in meses.items():
        clima_promedio[municipio][mes] = {
            "temp_max": round(sum(d["temp_max"] for d in dias) / len(dias), 1),
            "temp_min": round(sum(d["temp_min"] for d in dias) / len(dias), 1),
            "temp_media": round(sum(d["temp_media"] for d in dias) / len(dias), 1),
            "precipitacion": round(sum(d["precipitacion"] for d in dias) / len(dias), 1),
            "humedad": round(sum(d["humedad"] for d in dias) / len(dias), 1),
        }

# 2. Cargar cultivos
print("Cargando cultivos...")
cultivos = []
with open("assets/data/cultivos_sierra_norte.csv", encoding="utf-8") as f:
    for row in csv.DictReader(f):
        municipios_cultivo = [m.strip() for m in row["municipios"].split("|")]
        meses_siembra = row["meses_siembra"].strip()
        meses_cosecha = row["meses_cosecha"].strip()
        cultivos.append({
            "cultivo": row["cultivo"].strip(),
            "altitud_min": int(row["altitud_min"]),
            "altitud_max": int(row["altitud_max"]),
            "temp_min": float(row["temp_min"]),
            "temp_max": float(row["temp_max"]),
            "precip_min": float(row["precipitacion_min_mm"]),
            "precip_max": float(row["precipitacion_max_mm"]),
            "humedad_min": float(row["humedad_min"]),
            "humedad_max": float(row["humedad_max"]),
            "meses_siembra": meses_siembra,
            "meses_cosecha": meses_cosecha,
            "municipios": municipios_cultivo,
            "notas": row["notas"].strip(),
        })

# 3. Cargar altitudes de municipios
municipios_info = [
    {"nombre": "Abejones", "altitud": 2200, "distrito": "Ixtlán"},
    {"nombre": "Capulálpam de Méndez", "altitud": 2000, "distrito": "Ixtlán"},
    {"nombre": "Guelatao de Juárez", "altitud": 1750, "distrito": "Ixtlán"},
    {"nombre": "Ixtlán de Juárez", "altitud": 1950, "distrito": "Ixtlán"},
    {"nombre": "Natividad", "altitud": 1800, "distrito": "Ixtlán"},
    {"nombre": "San Juan Chicomezúchil", "altitud": 2100, "distrito": "Ixtlán"},
    {"nombre": "San Juan Evangelista Analco", "altitud": 1900, "distrito": "Ixtlán"},
    {"nombre": "San Miguel Amatlán", "altitud": 2300, "distrito": "Ixtlán"},
    {"nombre": "San Miguel del Río", "altitud": 1600, "distrito": "Ixtlán"},
    {"nombre": "San Pablo Macuiltianguis", "altitud": 1700, "distrito": "Ixtlán"},
    {"nombre": "San Pedro Yaneri", "altitud": 1400, "distrito": "Ixtlán"},
    {"nombre": "San Pedro Yólox", "altitud": 1500, "distrito": "Ixtlán"},
    {"nombre": "Santa Catarina Ixtepeji", "altitud": 2400, "distrito": "Ixtlán"},
    {"nombre": "Santiago Comaltepec", "altitud": 1300, "distrito": "Ixtlán"},
    {"nombre": "Santiago Xiacuí", "altitud": 1850, "distrito": "Ixtlán"},
    {"nombre": "Santo Tomás Mazaltepec", "altitud": 2100, "distrito": "Ixtlán"},
    {"nombre": "San Andrés Solaga", "altitud": 1800, "distrito": "Villa Alta"},
    {"nombre": "San Andrés Yaa", "altitud": 1600, "distrito": "Villa Alta"},
    {"nombre": "San Baltazar Yatzachi el Bajo", "altitud": 1700, "distrito": "Villa Alta"},
    {"nombre": "San Cristóbal Lachirioag", "altitud": 1500, "distrito": "Villa Alta"},
    {"nombre": "San Francisco Cajonos", "altitud": 1650, "distrito": "Villa Alta"},
    {"nombre": "San Francisco Yatzachi el Alto", "altitud": 1900, "distrito": "Villa Alta"},
    {"nombre": "San Ildefonso Villa Alta", "altitud": 1200, "distrito": "Villa Alta"},
    {"nombre": "San Juan Tabaá", "altitud": 1550, "distrito": "Villa Alta"},
    {"nombre": "San Juan Yaeé", "altitud": 1700, "distrito": "Villa Alta"},
    {"nombre": "San Juan Yatzona", "altitud": 1400, "distrito": "Villa Alta"},
    {"nombre": "San Melchor Betaza", "altitud": 1750, "distrito": "Villa Alta"},
    {"nombre": "San Miguel Amatitlán", "altitud": 1300, "distrito": "Villa Alta"},
    {"nombre": "San Miguel Quetzaltepec", "altitud": 1000, "distrito": "Villa Alta"},
    {"nombre": "San Pablo Yaganiza", "altitud": 1600, "distrito": "Villa Alta"},
    {"nombre": "San Pedro Cajonos", "altitud": 1500, "distrito": "Villa Alta"},
    {"nombre": "San Pedro Ocotepec", "altitud": 900, "distrito": "Villa Alta"},
    {"nombre": "San Pedro y San Pablo Ayutla", "altitud": 1100, "distrito": "Villa Alta"},
    {"nombre": "Santa María Temaxcalapa", "altitud": 1000, "distrito": "Villa Alta"},
    {"nombre": "Santa María Yalina", "altitud": 1600, "distrito": "Villa Alta"},
    {"nombre": "Santiago Camotlán", "altitud": 850, "distrito": "Villa Alta"},
    {"nombre": "Santiago Choápam", "altitud": 800, "distrito": "Villa Alta"},
    {"nombre": "Santiago Lalopa", "altitud": 1650, "distrito": "Villa Alta"},
    {"nombre": "Santiago Laxopa", "altitud": 1800, "distrito": "Villa Alta"},
    {"nombre": "Santiago Zoochila", "altitud": 1900, "distrito": "Villa Alta"},
    {"nombre": "Santo Domingo Roayaga", "altitud": 1300, "distrito": "Villa Alta"},
    {"nombre": "Santo Domingo Xagacía", "altitud": 1700, "distrito": "Villa Alta"},
    {"nombre": "Tabaá", "altitud": 1400, "distrito": "Villa Alta"},
    {"nombre": "Talea de Castro", "altitud": 1500, "distrito": "Villa Alta"},
    {"nombre": "Tamazulapam del Espíritu Santo", "altitud": 1750, "distrito": "Villa Alta"},
    {"nombre": "Zoogocho", "altitud": 1850, "distrito": "Villa Alta"},
    {"nombre": "Alotepec", "altitud": 2200, "distrito": "Mixe"},
    {"nombre": "Asunción Cacalotepec", "altitud": 1800, "distrito": "Mixe"},
    {"nombre": "Ayutla Mixe", "altitud": 1200, "distrito": "Mixe"},
    {"nombre": "Cacalotepec", "altitud": 1700, "distrito": "Mixe"},
    {"nombre": "Cotzocón", "altitud": 400, "distrito": "Mixe"},
    {"nombre": "Dolores Hidalgo Mixe", "altitud": 900, "distrito": "Mixe"},
    {"nombre": "El Espinal", "altitud": 1500, "distrito": "Mixe"},
    {"nombre": "Mixistlán de la Reforma", "altitud": 2600, "distrito": "Mixe"},
    {"nombre": "Ocotepec", "altitud": 1000, "distrito": "Mixe"},
    {"nombre": "Quetzaltepec", "altitud": 1100, "distrito": "Mixe"},
    {"nombre": "San Juan Cotzocón", "altitud": 350, "distrito": "Mixe"},
    {"nombre": "San Juan Guichicovi", "altitud": 150, "distrito": "Mixe"},
    {"nombre": "San Lucas Camotlán", "altitud": 950, "distrito": "Mixe"},
    {"nombre": "San Miguel Yotao", "altitud": 1600, "distrito": "Mixe"},
    {"nombre": "Santa María Alotepec", "altitud": 2000, "distrito": "Mixe"},
    {"nombre": "Santiago Atitlán", "altitud": 1400, "distrito": "Mixe"},
    {"nombre": "Santiago Zacatepec", "altitud": 2400, "distrito": "Mixe"},
    {"nombre": "Tepantlali", "altitud": 700, "distrito": "Mixe"},
    {"nombre": "Totontepec Villa de Morelos", "altitud": 2000, "distrito": "Mixe"},
    {"nombre": "San Pedro y San Pablo Teposcolula", "altitud": 1400, "distrito": "Villa Alta"},
    {"nombre": "San Pedro y San Pablo Tlistac", "altitud": 1350, "distrito": "Villa Alta"},
]

altitudes = {m["nombre"]: m["altitud"] for m in municipios_info}

# 4. Generar recomendaciones por municipio y mes
print("Generando recomendaciones...")
resultado = {}

for info in municipios_info:
    nombre = info["nombre"]
    altitud = info["altitud"]
    distrito = info["distrito"]
    clima_mun = clima_promedio.get(nombre, {})

    resultado[nombre] = {
        "distrito": distrito,
        "altitud": altitud,
        "clima_mensual": clima_mun,
        "recomendaciones_por_mes": {}
    }

    for mes in range(1, 13):
        clima_mes = clima_mun.get(mes, {})
        if not clima_mes:
            continue

        temp = clima_mes["temp_media"]
        precip = clima_mes["precipitacion"]
        humedad = clima_mes["humedad"]

        recomendados = []
        for c in cultivos:
            # Verificar si el municipio cultiva esto
            if nombre not in c["municipios"]:
                continue
            # Verificar altitud
            if not (c["altitud_min"] <= altitud <= c["altitud_max"]):
                continue
            # Verificar temperatura
            if not (c["temp_min"] <= temp <= c["temp_max"]):
                continue

            # Score de idoneidad
            score = 100
            if precip < c["precip_min"]:
                score -= 20
            elif precip > c["precip_max"]:
                score -= 10
            if humedad < c["humedad_min"]:
                score -= 15
            elif humedad > c["humedad_max"]:
                score -= 5

            recomendados.append({
                "cultivo": c["cultivo"],
                "score": score,
                "meses_siembra": c["meses_siembra"],
                "meses_cosecha": c["meses_cosecha"],
                "notas": c["notas"],
            })

        recomendados.sort(key=lambda x: x["score"], reverse=True)
        resultado[nombre]["recomendaciones_por_mes"][mes] = recomendados[:3]

# 5. Guardar JSON
with open("assets/data/recomendaciones.json", "w", encoding="utf-8") as f:
    json.dump(resultado, f, ensure_ascii=False, indent=2)

total = sum(
    len(meses)
    for m in resultado.values()
    for meses in [m["recomendaciones_por_mes"]]
)
print(f"✅ recomendaciones.json generado")
print(f"   Municipios: {len(resultado)}")
print(f"   Entradas mes-municipio: {total}")
