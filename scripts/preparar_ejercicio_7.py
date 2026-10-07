#!/usr/bin/env python3
"""Crea y valida la capa semantica persistente usada por Metabase."""

from pathlib import Path
import argparse
import sys

import duckdb

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DATABASE = ROOT / "data" / "processed" / "ejercicio_6.duckdb"
VIEW_SQL = ROOT / "ejercicio_7_vistas.sql"
REQUIRED_COLUMNS = {
    "data_year", "taxi_type", "pep_pickup_datetime", "pep_dropoff_datetime",
    "passenger_count", "trip_distance", "PULocationID", "DOLocationID",
    "payment_type", "fare_amount", "tip_amount", "total_amount",
}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", type=Path, default=DEFAULT_DATABASE)
    args = parser.parse_args()
    database = args.database.resolve()
    if not database.is_file():
        parser.error(
            f"no existe {database}. Ejecute primero: "
            "python scripts/benchmark_ejercicio_6.py --repetitions 1"
        )

    connection = duckdb.connect(str(database))
    try:
        tables = {row[0] for row in connection.execute("SHOW TABLES").fetchall()}
        if "trips" not in tables:
            raise RuntimeError("la base no contiene la tabla materializada 'trips'")
        actual = {
            row[0] for row in connection.execute(
                "SELECT column_name FROM information_schema.columns "
                "WHERE table_name = 'trips'"
            ).fetchall()
        }
        missing = sorted(REQUIRED_COLUMNS - actual)
        if missing:
            raise RuntimeError("faltan columnas en trips: " + ", ".join(missing))

        connection.execute("BEGIN TRANSACTION")
        try:
            connection.execute(VIEW_SQL.read_text(encoding="utf-8"))
            connection.execute("COMMIT")
        except Exception:
            connection.execute("ROLLBACK")
            raise

        total, valid, invalid = connection.execute(
            "SELECT count(*), count(*) FILTER (WHERE es_valido), "
            "count(*) FILTER (WHERE NOT es_valido) FROM viajes_analiticos"
        ).fetchone()
        print(f"Base: {database}")
        print(f"Registros: {total:,}; validos: {valid:,}; invalidos: {invalid:,}")
        print("Vistas viajes_base y viajes_analiticos creadas correctamente.")
        return 0
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    finally:
        connection.close()


if __name__ == "__main__":
    raise SystemExit(main())
