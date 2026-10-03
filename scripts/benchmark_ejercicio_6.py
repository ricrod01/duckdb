#!/usr/bin/env python3
"""Compara consultas directas a Parquet con una tabla materializada DuckDB."""

import argparse
import os
import platform
import time
from pathlib import Path

import duckdb
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DATABASE = ROOT / "data" / "processed" / "ejercicio_6.duckdb"
DEFAULT_OUTPUT = ROOT / "docs" / "benchmark_ejercicio_6.csv"

DIRECT_SOURCE = """(
    SELECT 2024 AS data_year, 'yellow' AS taxi_type,
           pep_pickup_datetime, pep_dropoff_datetime, passenger_count,
           trip_distance, PULocationID, DOLocationID, payment_type,
           fare_amount, tip_amount, total_amount
    FROM read_parquet('../data/processed/yellow_2024.parquet')
    WHERE pep_pickup_datetime >= DATE '2024-01-01'
      AND pep_pickup_datetime < DATE '2025-01-01'
    UNION ALL
    SELECT 2024 AS data_year, 'green' AS taxi_type,
           pep_pickup_datetime, pep_dropoff_datetime, passenger_count,
           trip_distance, PULocationID, DOLocationID, payment_type,
           fare_amount, tip_amount, total_amount
    FROM read_parquet('../data/processed/green_2024.parquet')
    WHERE pep_pickup_datetime >= DATE '2024-01-01'
      AND pep_pickup_datetime < DATE '2025-01-01'
    UNION ALL
    SELECT 2026 AS data_year, 'yellow' AS taxi_type,
           pep_pickup_datetime, pep_dropoff_datetime, passenger_count,
           trip_distance, PULocationID, DOLocationID, payment_type,
           fare_amount, tip_amount, total_amount
    FROM read_parquet('../data/processed/yellow_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
    UNION ALL
    SELECT 2026 AS data_year, 'green' AS taxi_type,
           pep_pickup_datetime, pep_dropoff_datetime, passenger_count,
           trip_distance, PULocationID, DOLocationID, payment_type,
           fare_amount, tip_amount, total_amount
    FROM read_parquet('../data/processed/green_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
) AS source_data"""

SCENARIOS = (
    ("2026_partial", (2026,)),
    ("2024_full", (2024,)),
    ("2024_and_2026", (2024, 2026)),
)

QUERIES = {
    "q1_trip_characteristics": "ejercicio_6_2.sql",
    "q2_monthly_behavior": "ejercicio_6_3.sql",
    "q3_payment_distribution": "ejercicio_6_4.sql",
}


def read_sql(filename: str) -> str:
    return (ROOT / "sql" / filename).read_text(encoding="utf-8").strip().rstrip(";")


def render(template: str, source: str, years: tuple[int, ...]) -> str:
    year_filter = "data_year IN (" + ", ".join(map(str, years)) + ")"
    return template.replace("{{SOURCE}}", source).replace("{{YEAR_FILTER}}", year_filter)


def execute_timed(connection: duckdb.DuckDBPyConnection, query: str) -> tuple[float, pd.DataFrame]:
    start = time.perf_counter()
    result = connection.execute(query).df()
    return time.perf_counter() - start, result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repetitions", type=int, default=3)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument(
        "--skip-materialize",
        action="store_true",
        help="reutiliza la tabla trips existente en lugar de reconstruirla",
    )
    args = parser.parse_args()
    if args.repetitions < 1:
        parser.error("--repetitions debe ser mayor que cero")

    os.chdir(ROOT / "notebooks")
    DATABASE.parent.mkdir(parents=True, exist_ok=True)
    connection = duckdb.connect(str(DATABASE))

    if not args.skip_materialize:
        started = time.perf_counter()
        connection.execute(read_sql("ejercicio_6_1.sql"))
        materialization_seconds = time.perf_counter() - started
        print(f"Tabla trips materializada en {materialization_seconds:.3f} s")
    else:
        materialization_seconds = None
        connection.execute("SELECT 1 FROM trips LIMIT 1")

    table_rows = connection.execute("SELECT COUNT(*) FROM trips").fetchone()[0]
    print(f"Filas materializadas: {table_rows:,}")
    print(f"Plataforma: {platform.platform()}")
    print(f"DuckDB: {duckdb.__version__}; CPU logicos: {os.cpu_count()}")

    rows = []
    for scenario, years in SCENARIOS:
        year_filter = "data_year IN (" + ", ".join(map(str, years)) + ")"
        row_count = connection.execute(
            f"SELECT COUNT(*) FROM trips WHERE {year_filter}"
        ).fetchone()[0]

        for query_name, filename in QUERIES.items():
            template = read_sql(filename)
            direct_query = render(template, DIRECT_SOURCE, years)
            table_query = render(template, "trips", years)

            direct_result = connection.execute(direct_query).df()
            table_result = connection.execute(table_query).df()
            pd.testing.assert_frame_equal(
                direct_result,
                table_result,
                check_exact=False,
                rtol=1e-9,
                atol=1e-9,
            )

            for repetition in range(1, args.repetitions + 1):
                strategies = (
                    (("parquet", direct_query), ("duckdb_table", table_query))
                    if repetition % 2
                    else (("duckdb_table", table_query), ("parquet", direct_query))
                )
                for strategy, query in strategies:
                    seconds, _ = execute_timed(connection, query)
                    rows.append(
                        {
                            "scenario": scenario,
                            "years": "+".join(map(str, years)),
                            "row_count": row_count,
                            "query": query_name,
                            "strategy": strategy,
                            "repetition": repetition,
                            "seconds": seconds,
                            "materialization_seconds": materialization_seconds,
                            "duckdb_version": duckdb.__version__,
                            "logical_cpus": os.cpu_count(),
                        }
                    )
                    print(
                        f"{scenario:14} {query_name:25} {strategy:12} "
                        f"r{repetition}: {seconds:.4f} s"
                    )

    results = pd.DataFrame(rows)
    output = args.output if args.output.is_absolute() else ROOT / args.output
    output.parent.mkdir(parents=True, exist_ok=True)
    results.to_csv(output, index=False)

    summary = (
        results.groupby(["scenario", "row_count", "query", "strategy"], as_index=False)
        .agg(median_seconds=("seconds", "median"))
    )
    print("\nResumen (mediana de segundos):")
    print(summary.to_string(index=False))
    print(f"\nResultados guardados en {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
