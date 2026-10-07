#!/usr/bin/env python3
"""Comprueba cobertura y compatibilidad de las consultas tras incorporar 2025."""

from pathlib import Path
import argparse
import sys

import duckdb

ROOT = Path(__file__).resolve().parents[1]
DATABASE = ROOT / "data" / "processed" / "ejercicio_6.duckdb"
EJERCICIO_8 = sorted((ROOT / "sql").glob("ejercicio_8_*.sql"))
EJERCICIO_7 = sorted(ROOT.glob("ejercicio_7_*.sql"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", type=Path, default=DATABASE)
    args = parser.parse_args()
    if not args.database.is_file():
        parser.error(f"no existe {args.database}")

    con = duckdb.connect(str(args.database), read_only=True)
    fallos = []
    try:
        cobertura = con.execute(
            "SELECT data_year, taxi_type, count(*) FROM trips "
            "GROUP BY data_year, taxi_type"
        ).fetchall()
        observadas = {(a, t) for a, t, n in cobertura if n > 0}
        esperadas = {(a, t) for a in (2024, 2025, 2026)
                     for t in ("green", "yellow")}
        if observadas != esperadas:
            fallos.append(f"faltan conjuntos: {sorted(esperadas - observadas)}")

        consultas = [p for p in EJERCICIO_7 if p.name != "ejercicio_7_vistas.sql"]
        consultas += [p for p in EJERCICIO_8 if not p.name.endswith(("_1_y.sql", "_1_g.sql"))]
        for ruta in consultas:
            try:
                resultado = con.execute(ruta.read_text(encoding="utf-8"))
                resultado.fetchone()
                print(f"OK  {ruta.relative_to(ROOT)}")
            except Exception as exc:
                fallos.append(f"{ruta.name}: {exc}")

        for nombre in ("ejercicio_6_2.sql", "ejercicio_6_3.sql", "ejercicio_6_4.sql"):
            plantilla = (ROOT / "sql" / nombre).read_text(encoding="utf-8")
            consulta = (plantilla.replace("{{SOURCE}}", "trips")
                         .replace("{{YEAR_FILTER}}", "data_year IN (2024, 2025, 2026)"))
            try:
                con.execute(consulta).fetchone()
                print(f"OK  sql/{nombre} (tres anios)")
            except Exception as exc:
                fallos.append(f"{nombre}: {exc}")
    finally:
        con.close()

    if fallos:
        print("\nVALIDACION FALLIDA", file=sys.stderr)
        for fallo in fallos:
            print(f"- {fallo}", file=sys.stderr)
        return 1
    print("\nValidacion completa: seis conjuntos y consultas compatibles.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
