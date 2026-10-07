#!/usr/bin/env python3
"""Genera el informe Markdown y sus graficas para el Ejercicio 8."""

from pathlib import Path
import argparse

import duckdb
import matplotlib.pyplot as plt
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DATABASE = ROOT / "data" / "processed" / "ejercicio_6.duckdb"
DOCS = ROOT / "docs"
FIGURES = DOCS / "ejercicio_8_figuras"

SQL_FILES = {
    "cobertura": "sql/ejercicio_8_cobertura.sql",
    "anuales": "sql/ejercicio_8_indicadores_anuales.sql",
    "comparables": "sql/ejercicio_8_indicadores_comparables.sql",
    "mensuales": "sql/ejercicio_8_evolucion_mensual.sql",
    "pagos": "sql/ejercicio_8_formas_pago.sql",
}


def leer_sql(relativa: str) -> str:
    return (ROOT / relativa).read_text(encoding="utf-8").strip()


def valor_md(valor) -> str:
    if pd.isna(valor):
        return ""
    if isinstance(valor, float):
        return f"{valor:,.2f}"
    if isinstance(valor, int):
        return f"{valor:,}"
    return str(valor).replace("|", "\\|")


def tabla_md(df: pd.DataFrame) -> str:
    encabezado = "| " + " | ".join(map(str, df.columns)) + " |"
    separador = "|" + "|".join("---" for _ in df.columns) + "|"
    filas = [
        "| " + " | ".join(valor_md(v) for v in fila) + " |"
        for fila in df.itertuples(index=False, name=None)
    ]
    return "\n".join([encabezado, separador, *filas])


def cambio_pct(inicial: float, final: float) -> float:
    return 100.0 * (final - inicial) / inicial if inicial else float("nan")


def describir_cambios(comparables: pd.DataFrame) -> list[str]:
    primero = int(comparables["data_year"].min())
    ultimo = int(comparables["data_year"].max())
    meses = int(comparables["ultimo_mes_comparable"].min())
    patrones = []
    for metrica, etiqueta, unidad in (
        ("viajes", "volumen de viajes", "%"),
        ("ticket_mediano", "ticket mediano", "%"),
        ("distancia_mediana", "distancia mediana", "%"),
    ):
        partes = []
        for taxi in ("yellow", "green"):
            datos = comparables[comparables["taxi_type"] == taxi].set_index("data_year")
            if primero in datos.index and ultimo in datos.index:
                variacion = cambio_pct(float(datos.loc[primero, metrica]),
                                       float(datos.loc[ultimo, metrica]))
                direccion = "aumento" if variacion >= 0 else "disminuyo"
                partes.append(f"{taxi} {direccion} {abs(variacion):.1f}{unidad}")
        patrones.append(
            f"**{etiqueta.capitalize()}:** entre {primero} y {ultimo}, "
            + "; ".join(partes)
            + f", comparando enero-mes {meses}."
        )
    return patrones


def graficas(mensuales: pd.DataFrame, comparables: pd.DataFrame) -> None:
    FIGURES.mkdir(parents=True, exist_ok=True)
    colores = {2024: "#4C78A8", 2025: "#F58518", 2026: "#54A24B"}

    for metrica, titulo, ylabel, archivo in (
        ("viajes", "Evolucion mensual del volumen", "Viajes", "viajes_mensuales.png"),
        ("ticket_mediano", "Evolucion mensual del ticket mediano", "USD", "ticket_mediano.png"),
    ):
        fig, axes = plt.subplots(1, 2, figsize=(13, 4.5), sharex=True)
        for ax, taxi in zip(axes, ("yellow", "green")):
            sub = mensuales[mensuales["taxi_type"] == taxi]
            for anio, datos in sub.groupby("data_year"):
                ax.plot(datos["mes"], datos[metrica], marker="o", markersize=3,
                        label=str(anio), color=colores.get(int(anio)))
            ax.set_title(taxi.capitalize())
            ax.set_xlabel("Mes")
            ax.set_ylabel(ylabel)
            ax.set_xticks(range(1, 13))
            ax.grid(alpha=.25)
            ax.legend(title="Anio")
        fig.suptitle(titulo)
        fig.tight_layout()
        fig.savefig(FIGURES / archivo, dpi=160, bbox_inches="tight")
        plt.close(fig)

    pivot = comparables.pivot(index="data_year", columns="taxi_type", values="viajes")
    ax = pivot.plot(kind="bar", figsize=(9, 4.5), color=["#54A24B", "#F2CF5B"])
    ax.set_title("Viajes con ventana temporal comparable")
    ax.set_xlabel("Anio")
    ax.set_ylabel("Viajes")
    ax.tick_params(axis="x", rotation=0)
    ax.grid(axis="y", alpha=.25)
    plt.tight_layout()
    plt.savefig(FIGURES / "viajes_comparables.png", dpi=160, bbox_inches="tight")
    plt.close()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", type=Path, default=DATABASE)
    parser.add_argument("--output", type=Path, default=DOCS / "ejercicio_8_reporte.md")
    args = parser.parse_args()
    if not args.database.is_file():
        parser.error(f"no existe {args.database}; ejecute preparar_ejercicio_8.py")

    connection = duckdb.connect(str(args.database), read_only=True)
    try:
        resultados = {
            nombre: connection.execute(leer_sql(ruta)).df()
            for nombre, ruta in SQL_FILES.items()
        }
    finally:
        connection.close()

    combinaciones = set(zip(resultados["cobertura"].data_year,
                            resultados["cobertura"].taxi_type))
    esperadas = {(a, t) for a in (2024, 2025, 2026) for t in ("yellow", "green")}
    if combinaciones != esperadas:
        parser.error(f"faltan conjuntos en trips: {sorted(esperadas - combinaciones)}")

    graficas(resultados["mensuales"], resultados["comparables"])
    patrones = describir_cambios(resultados["comparables"])
    consultas = "\n\n".join(
        f"### `{ruta}`\n\n```sql\n{leer_sql(ruta)}\n```"
        for ruta in SQL_FILES.values()
    )
    informe = f"""# Ejercicio 8: incorporación de 2025 y análisis completo

## Metodología

Se integraron los registros Yellow y Green Taxi de 2024, 2025 y 2026 en la
tabla materializada `trips`. Los indicadores utilizan `viajes_analiticos` y sus
reglas de calidad. Como 2026 puede estar incompleto, se presentan resultados
anuales observados y una comparación hasta el último mes común a los seis
conjuntos.

## Cobertura de datos

{tabla_md(resultados['cobertura'])}

## Indicadores observados

{tabla_md(resultados['anuales'])}

## Comparación temporal homogénea

{tabla_md(resultados['comparables'])}

![Viajes comparables](ejercicio_8_figuras/viajes_comparables.png)

## Evolución mensual

![Viajes mensuales](ejercicio_8_figuras/viajes_mensuales.png)

![Ticket mediano](ejercicio_8_figuras/ticket_mediano.png)

## Cambios y patrones identificados

1. {patrones[0]}
2. {patrones[1]}
3. {patrones[2]}

Estos cambios son descriptivos y no demuestran causalidad. La comparación usa
la misma ventana de meses para evitar confundir cobertura parcial con una caída
real de la actividad.

## Formas de pago

{tabla_md(resultados['pagos'])}

## Consultas utilizadas

{consultas}
"""
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(informe, encoding="utf-8")
    print(f"Informe generado: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
