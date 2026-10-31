"""Frases de razón armadas con datos, para que el modelo solo las redacte.

Los modelos chicos tienden a dar razones circulares ("siémbralo en junio porque
es cuando se siembra"); aquí la razón sale de los números.
"""

from app.schemas import Siembra

LLUVIA_POCA_MM = 60  # al mes


def frase_siembra(s: Siembra, mes_actual: str | None) -> str:
    meses = s.meses.lower()
    ls, la = s.lluvia_meses_siembra_mm, s.lluvia_mes_actual_mm

    if s.se_siembra_este_mes:
        frase = f"ahora es buen momento para sembrarlo: se siembra en {meses}"
        if la is not None:
            frase += f" y en {mes_actual or 'este mes'} suelen llover {la:.0f} mm"
        return frase

    frase = f"conviene sembrarlo en {meses}"
    if ls is None:
        return frase

    poca_agua = s.agua_cultivo == "bajo" and ls < LLUVIA_POCA_MM
    if poca_agua:
        frase += f", porque en esos meses llueve poco (unos {ls:.0f} mm al mes)"
    else:
        frase += f", porque en esos meses suelen llover {ls:.0f} mm al mes"
    # Comparar con el mes actual evita que el modelo confunda las dos épocas
    if la is not None and mes_actual:
        if ls > la * 1.2:
            frase += f", más que los {la:.0f} mm de {mes_actual}"
        elif ls < la * 0.8:
            frase += f", menos que los {la:.0f} mm de {mes_actual}"
    if poca_agua:
        frase += ", y este cultivo necesita poca agua"
    return frase
