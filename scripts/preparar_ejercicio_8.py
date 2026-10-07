#!/usr/bin/env python3
"""Procesa 2025, materializa los tres anios y valida la ampliacion."""

import os
from pathlib import Path
import sys

import duckdb

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
PROCESSED = ROOT / "data" / "processed"
DATABASE = PROCESSED / "ejercicio_6.duckdb"


def leer_sql(nombre: str) -> str:
    return (ROOT / nombre).read_text(encoding="utf-8").strip().rstrip(";")


def main() -> int:
    faltantes = []
    for taxi in ("yellow", "green"):
        archivos = sorted((RAW / taxi / "2025").glob("*.parquet"))
        if len(archivos) != 12:
            faltantes.append(f"{taxi} 2025: {len(archivos)}/12 archivos")
    if faltantes:
        print("ERROR: descarga 2025 incompleta: " + "; ".join(faltantes), file=sys.stderr)
        print("Ejecute: python scripts/download_data_ejercicio_8.py", file=sys.stderr)
        return 1

    PROCESSED.mkdir(parents=True, exist_ok=True)
    os.chdir(ROOT / "notebooks")  # conserva las rutas relativas de los SQL existentes
    connection = duckdb.connect()
    try:
        for taxi, sql_name in (
            ("yellow", "sql/ejercicio_8_1_y.sql"),
            ("green", "sql/ejercicio_8_1_g.sql"),
        ):
            destino = PROCESSED / f"{taxi}_2025.parquet"
            consulta = leer_sql(sql_name)
            connection.execute(
                f"COPY ({consulta}) TO '{destino.as_posix()}' "
                "(FORMAT PARQUET, COMPRESSION ZSTD, OVERWRITE_OR_IGNORE TRUE)"
            )
            filas = connection.execute(
                f"SELECT count(*) FROM read_parquet('{destino.as_posix()}')"
            ).fetchone()[0]
            print(f"{destino.name}: {filas:,} filas")
    finally:
        connection.close()

    database_connection = duckdb.connect(str(DATABASE))
    try:
        database_connection.execute(leer_sql("sql/ejercicio_6_1.sql"))
        database_connection.execute(leer_sql("ejercicio_7_vistas.sql"))
        control = database_connection.execute(
            "SELECT data_year, taxi_type, count(*) AS filas FROM trips "
            "GROUP BY data_year, taxi_type ORDER BY data_year, taxi_type"
        ).fetchall()
        esperadas = {(anio, taxi) for anio in (2024, 2025, 2026)
                     for taxi in ("green", "yellow")}
        observadas = {(anio, taxi) for anio, taxi, _ in control}
        if observadas != esperadas:
            raise RuntimeError(f"combinaciones incompletas: {sorted(esperadas - observadas)}")
        for anio, taxi, filas in control:
            print(f"trips {anio} {taxi}: {filas:,} filas")
    finally:
        database_connection.close()

    print(f"Base ampliada correctamente: {DATABASE}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
