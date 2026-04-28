# Lu-nisa 🌱

**Lu-nisa** es una aplicación móvil para agricultores de la Sierra Norte de Oaxaca que recomienda cultivos adecuados según el municipio, el mes del año y las condiciones visuales de la parcela analizadas con inteligencia artificial.

El nombre viene del zapoteco *lu nisa* — **"cara del agua"** — evocando la relación ancestral entre la tierra, el clima y el conocimiento agrícola de los pueblos de la sierra.

---

## El problema que resuelve

Los agricultores de la Sierra Norte enfrentan condiciones de altitud, temperatura y precipitación muy variables entre municipios que están a pocos kilómetros de distancia. La falta de información localizada y el acceso limitado a internet dificultan tomar decisiones sobre qué sembrar y cuándo. Lu-nisa funciona **completamente sin conexión** y habla el idioma del campo: simple, visual y directo.

---

## Tecnologías

| Capa | Tecnología |
|---|---|
| Mobile | Flutter 3 + Dart |
| Estado | Provider |
| Navegación | GoRouter + StatefulShellRoute |
| IA / Visión | ML Kit Image Labeling (on-device) |
| Persistencia | sqflite (SQLite local) |
| Datos | JSON offline — 804 entradas (67 municipios × 12 meses) |

Todo el procesamiento ocurre en el dispositivo. No se envían fotos ni datos a ningún servidor.

---

## Cómo funciona

```
Onboarding
    ↓
Selección de municipio   ←── base de datos de 67 municipios de la Sierra Norte
    ↓
Foto de la parcela       ←── ML Kit analiza la condición del suelo
    │                         (fértil / húmedo / seco)
    ↓
Recomendaciones          ←── cultivos ordenados por score según mes + condición
    │
    ↓
Historial                ←── registro local de todas las consultas
```

### Análisis visual con ML Kit

La pantalla de cámara permite tomar o seleccionar una foto del terreno. El modelo de ML Kit ejecutado localmente clasifica la condición de la parcela en tres categorías y ajusta el score de cada cultivo recomendado. Por ejemplo, un suelo húmedo favorece café y quelites; un suelo seco prioriza maíz criollo y frijol resistente.

### Datos offline

El archivo `assets/data/recomendaciones.json` contiene información de siembra, clima y cultivos para cada combinación de municipio y mes. Los datos cubren los distritos de **Ixtlán de Juárez**, **Villa Alta** y **Mixe**, los tres distritos que conforman la Sierra Norte de Oaxaca.

---

## Impacto social y cultural

La Sierra Norte de Oaxaca es una de las regiones con mayor biodiversidad agrícola de México y hogar de comunidades zapotecas, mixes y chinantecos que han cultivado la tierra por siglos. Sin embargo, enfrenta desafíos estructurales:

- **Conectividad limitada** — muchas comunidades no tienen acceso estable a internet
- **Migración rural** — los jóvenes abandonan el campo por falta de información y rentabilidad
- **Pérdida de conocimiento tradicional** — las variedades criollas y las épocas de siembra ancestrales se están olvidando

Lu-nisa apunta a estos tres puntos:

1. **Funciona sin internet** — puede usarse en la parcela, no solo en el pueblo
2. **Habla con datos locales** — las recomendaciones no son genéricas; respetan la variación climática entre Guelatao de Juárez (1,800 msnm) y Talea de Castro (900 msnm)
3. **Refuerza el conocimiento existente** — no reemplaza al agricultor, lo acompaña con información que complementa la experiencia de generaciones

La app está diseñada para ser usada por productores que tal vez nunca han usado una app agrícola: interfaz en español, íconos intuitivos, sin formularios complejos.

---

## Estructura del proyecto

```
lib/
├── core/
│   ├── data/          # Catálogo de municipios por distrito
│   ├── providers/     # AppProvider — estado global de la app
│   ├── theme/         # Paleta Material You (verde sierra)
│   └── widgets/       # Componentes compartidos
├── data/
│   ├── models/        # CultivoRecomendado, ClimaMes, Consulta
│   └── repositories/  # Carga y consulta del JSON offline
├── features/
│   ├── onboarding/    # Pantalla de bienvenida
│   ├── inicio/        # Hub principal con clima y acceso rápido
│   ├── municipio/     # Selección de municipio y distrito
│   ├── camara/        # Captura y análisis visual de la parcela
│   ├── recomendacion/ # Resultados: cultivos, clima, condición de suelo
│   ├── historial/     # Registro de consultas anteriores
│   └── perfil/        # Ajustes y ubicación del productor
└── ml/
    └── image_analyzer.dart  # Clasificación on-device con ML Kit
```

---

## Correr el proyecto

```bash
flutter pub get
flutter run
```

Requiere dispositivo Android físico (el modelo de ML Kit no funciona correctamente en emulador).

---

*Desarrollado en ITO Oaxaca — 8vo semestre, 2025.*
