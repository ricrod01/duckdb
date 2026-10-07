#!/usr/bin/env python3
"""Descarga idempotente de Yellow y Green Taxi para el anio 2025."""

import argparse
import sys
from pathlib import Path

import requests

ANIO = 2025
TIPOS_TAXI = ("yellow", "green")
URL_BASE = "https://d37ci6vzurychx.cloudfront.net/trip-data"
DIR_DESTINO = Path("data/raw")
TIEMPO_ESPERA = 60
INTENTOS = 3
BLOQUE = 1024 * 1024
SUFIJO_TEMPORAL = ".part"


def construir_nombre(tipo: str, mes: int) -> str:
    return f"{tipo}_tripdata_{ANIO}-{mes:02d}.parquet"


def construir_url(tipo: str, mes: int) -> str:
    return f"{URL_BASE}/{construir_nombre(tipo, mes)}"


def ruta_destino(tipo: str, mes: int) -> Path:
    return DIR_DESTINO / tipo / str(ANIO) / construir_nombre(tipo, mes)


def esta_publicado(url: str) -> bool:
    try:
        respuesta = requests.head(url, timeout=TIEMPO_ESPERA, allow_redirects=True)
        return respuesta.ok
    except requests.RequestException:
        return False


def formato_tamanio(n: float) -> str:
    for unidad in ("B", "KiB", "MiB", "GiB"):
        if n < 1024 or unidad == "GiB":
            return f"{n:.1f} {unidad}"
        n /= 1024
    return f"{n:.1f} GiB"


def descargar_archivo(url: str, destino: Path) -> int:
    destino.parent.mkdir(parents=True, exist_ok=True)
    temporal = destino.with_name(destino.name + SUFIJO_TEMPORAL)
    ultimo_error = None
    for intento in range(1, INTENTOS + 1):
        try:
            with requests.get(url, stream=True, timeout=TIEMPO_ESPERA) as respuesta:
                respuesta.raise_for_status()
                escritos = 0
                with temporal.open("wb") as archivo:
                    for bloque in respuesta.iter_content(chunk_size=BLOQUE):
                        if bloque:
                            archivo.write(bloque)
                            escritos += len(bloque)
            if escritos == 0:
                raise requests.RequestException("el servidor devolvio un archivo vacio")
            temporal.replace(destino)
            return escritos
        except requests.RequestException as error:
            ultimo_error = error
            temporal.unlink(missing_ok=True)
            if intento < INTENTOS:
                print(f"      intento {intento}/{INTENTOS} fallido; reintentando")
    raise requests.RequestException(f"no se pudo descargar {url}: {ultimo_error}")


def descargar(tipo: str, verificar: bool = False) -> dict:
    print(f"\n=== {tipo.upper()} {ANIO} ===")
    resumen = {"descargados": 0, "omitidos": 0, "faltantes": [], "fallidos": []}
    for mes in range(1, 13):
        etiqueta = f"{ANIO}-{mes:02d}"
        destino = ruta_destino(tipo, mes)
        if destino.is_file() and destino.stat().st_size > 0:
            print(f"  {etiqueta}  ya existe, se omite")
            resumen["omitidos"] += 1
            continue
        if verificar:
            print(f"  {etiqueta}  FALTA")
            resumen["faltantes"].append(etiqueta)
            continue
        url = construir_url(tipo, mes)
        if not esta_publicado(url):
            print(f"  {etiqueta}  no publicado")
            resumen["faltantes"].append(etiqueta)
            continue
        print(f"  {etiqueta}  descargando...")
        try:
            escritos = descargar_archivo(url, destino)
            print(f"  {etiqueta}  listo ({formato_tamanio(escritos)})")
            resumen["descargados"] += 1
        except requests.RequestException as error:
            print(f"  {etiqueta}  ERROR: {error}")
            resumen["fallidos"].append(etiqueta)
    return resumen


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--taxi", choices=(*TIPOS_TAXI, "all"), default="all")
    parser.add_argument(
        "--verify-only", action="store_true",
        help="comprueba archivos locales sin hacer solicitudes ni descargas",
    )
    args = parser.parse_args()
    tipos = TIPOS_TAXI if args.taxi == "all" else (args.taxi,)
    total = {"descargados": 0, "omitidos": 0, "faltantes": [], "fallidos": []}
    for tipo in tipos:
        resultado = descargar(tipo, args.verify_only)
        for clave in ("descargados", "omitidos"):
            total[clave] += resultado[clave]
        for clave in ("faltantes", "fallidos"):
            total[clave].extend(f"{tipo} {x}" for x in resultado[clave])
    print("\nRESUMEN")
    print(f"  descargados : {total['descargados']}")
    print(f"  ya existian : {total['omitidos']}")
    print(f"  faltantes   : {len(total['faltantes'])}")
    print(f"  fallidos    : {len(total['fallidos'])}")
    if args.verify_only and total["faltantes"]:
        print("  faltan      : " + ", ".join(total["faltantes"]))
    return 1 if total["fallidos"] or (args.verify_only and total["faltantes"]) else 0


if __name__ == "__main__":
    sys.exit(main())
