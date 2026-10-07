#!/usr/bin/env python3
"""Ejecuta todas las consultas del Ejercicio 7 y falla ante errores SQL."""

from pathlib import Path
import argparse
import sys

import duckdb

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DATABASE = ROOT / "data" / "processed" / "ejercicio_6.duckdb"
QUERIES = sorted(ROOT.glob("ejercicio_7_*.sql"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", type=Path, default=DEFAULT_DATABASE)
    args = parser.parse_args()
    database = args.database.resolve()
    if not database.is_file():
        parser.error(f"no existe {database}")

    connection = duckdb.connect(str(database), read_only=True)
    failures = []
    try:
        for path in QUERIES:
            if path.name == "ejercicio_7_vistas.sql":
                continue
            try:
                result = connection.execute(path.read_text(encoding="utf-8"))
                sample = result.fetchone()
                print(f"OK  {path.name}: columnas={len(result.description)}, muestra={sample}")
            except Exception as exc:
                failures.append((path.name, str(exc)))
                print(f"ERROR  {path.name}: {exc}", file=sys.stderr)
    finally:
        connection.close()

    if failures:
        print(f"Fallaron {len(failures)} consulta(s).", file=sys.stderr)
        return 1
    print("Todas las consultas del Ejercicio 7 se ejecutaron correctamente.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
