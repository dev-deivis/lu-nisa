from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator

MAX_PALABRAS_OBSERVACIONES = 25


class ParcelaAnalisis(BaseModel):
    """Atributos observables de la foto. Nada de fertilidad, nutrientes ni pH."""

    model_config = ConfigDict(extra="forbid")

    es_parcela: bool
    suelo_desnudo: bool | Literal["no_determinable"]
    humedad_aparente: Literal["seca", "humeda", "encharcada", "no_determinable"]
    pendiente: Literal["plana", "moderada", "fuerte", "no_determinable"]
    piedras: Literal["pocas", "muchas", "no_determinable"]
    cobertura_vegetal: Literal["nula", "parcial", "total"]
    # Informativo: se devuelve pero ninguna lógica lo usa
    confianza: Literal["baja", "media", "alta"]
    observaciones: str

    @field_validator("observaciones")
    @classmethod
    def recortar_observaciones(cls, v: str) -> str:
        # Se recorta en vez de rechazar: no vale la pena reintentar por esto
        palabras = v.split()
        if len(palabras) > MAX_PALABRAS_OBSERVACIONES:
            return " ".join(palabras[:MAX_PALABRAS_OBSERVACIONES]) + "…"
        return " ".join(palabras)


class AnalisisRespuesta(BaseModel):
    analisis: ParcelaAnalisis
    # true cuando respondió el modelo local, que no distingue bien la humedad
    humedad_preguntar_usuario: bool
    # Por qué se usó el respaldo local (None si respondió el proveedor preferido)
    respaldo: Literal["sin_conexion", "error_gemini", "respuesta_invalida", "sin_api_key"] | None
    proveedor: str
    modelo: str
    intentos: int
    latencia_ms: int


class DatoRegla(BaseModel):
    valor: str | int | float | bool
    # foto → "se ve", campesino → "nos dijiste", datos → históricos del municipio
    fuente: Literal["foto", "campesino", "datos"]


class Siembra(BaseModel):
    """Fecha de siembra del cultivo; con esto el backend arma la razón (no el modelo)."""

    meses: str = Field(min_length=1)  # "junio-julio"
    se_siembra_este_mes: bool
    # Lluvia total del mes, promedio histórico (mm)
    lluvia_meses_siembra_mm: float | None = None
    lluvia_mes_actual_mm: float | None = None
    agua_cultivo: Literal["bajo", "medio", "alto"] | None = None


class ExplicarEntrada(BaseModel):
    municipio: str = Field(min_length=1)
    cultivo: str = Field(min_length=1)
    puntaje: int = Field(ge=0, le=100)
    # Mes en que se hace la consulta (ej. "octubre"), para distinguirlo de la fecha de siembra
    mes_actual: str | None = None
    siembra: Siembra | None = None
    datos_regla: dict[str, DatoRegla] = {}


class ExplicarRespuesta(BaseModel):
    explicacion: str
    proveedor: str
    modelo: str
    latencia_ms: int
