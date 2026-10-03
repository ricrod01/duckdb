#!/usr/bin/env python3
"""Descarga los archivos Parquet de 2024 del NYC TLC Trip Record Data.

Esta copia del descargador pertenece al ejercicio 5. Conserva intacto el
script original de 2026 y almacena los nuevos archivos en directorios
separados por tipo de taxi y anio.

Uso:
    python scripts/download_data_ejercicio_5.py
    python scripts/download_data_ejercicio_5.py --taxi yellow
    python scripts/download_data_ejercicio_5.py --taxi green

Los archivos se guardan en:
    data/raw/<tipo>/2024/<nombre-original>.parquet
"""

import argparse
import sys
from pathlib import Path

import requests

ANIO = 2024
TIPOS_TAXI = ("yellow", "green")
URL_BASE = "https://d37ci6vzurychx.cloudfront.net/trip-data"
DIR_DESTINO = Path("data/raw")

TIEMPO_ESPERA = 60
INTENTOS = 3
BLOQUE = 1024 * 1024
SUFIJO_TEMPORAL = ".part"


def construir_nombre(tipo: str, mes: int) -> str:
    """Construye el nombre oficial del archivo mensual de la TLC."""
    return f"{tipo}_tripdata_{ANIO}-{mes:02d}.parquet"


def construir_url(tipo: str, mes: int) -> str:
    """Construye la URL oficial del archivo mensual."""
    return f"{URL_BASE}/{construir_nombre(tipo, mes)}"


def ruta_destino(tipo: str, mes: int) -> Path:
    """Devuelve la ruta local separada por tipo de taxi y anio."""
    return DIR_DESTINO / tipo / str(ANIO) / construir_nombre(tipo, mes)


def esta_publicado(url: str) -> bool:
    """Indica si el archivo existe en el servidor sin descargar su contenido."""
    try:
        respuesta = requests.head(url, timeout=TIEMPO_ESPERA, allow_redirects=True)
    except requests.RequestException:
        return False
    return respuesta.ok


def formato_tamanio(n: float) -> str:
    """Presenta una cantidad de bytes con una unidad legible."""
    for unidad in ("B", "KiB", "MiB", "GiB"):
        if n < 1024 or unidad == "GiB":
            return f"{n:.1f} {unidad}"
        n /= 1024
    return f"{n:.1f} GiB"


def descargar_archivo(url: str, destino: Path) -> int:
    """Descarga un archivo de forma atomica y devuelve los bytes escritos."""
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
                print(f"      intento {intento}/{INTENTOS} fallido ({error}); reintentando")

    raise requests.RequestException(f"no se pudo descargar {url}: {ultimo_error}")


def descargar(tipo: str) -> dict:
    """Descarga los doce archivos mensuales de 2024 para un tipo de taxi."""
    print(f"\n=== {tipo.upper()} {ANIO} ===")
    resumen = {"descargados": 0, "omitidos": 0, "no_publicados": [], "fallidos": []}

    for mes in range(1, 13):
        etiqueta = f"{ANIO}-{mes:02d}"
        destino = ruta_destino(tipo, mes)

        if destino.exists() and destino.stat().st_size > 0:
            print(f"  {etiqueta}  ya existe, se omite")
            resumen["omitidos"] += 1
            continue

        url = construir_url(tipo, mes)
        if not esta_publicado(url):
            print(f"  {etiqueta}  no publicado por la TLC")
            resumen["no_publicados"].append(etiqueta)
            continue

        print(f"  {etiqueta}  descargando...")
        try:
            escritos = descargar_archivo(url, destino)
        except requests.RequestException as error:
            print(f"  {etiqueta}  ERROR: {error}")
            resumen["fallidos"].append(etiqueta)
        else:
            print(f"  {etiqueta}  listo ({formato_tamanio(escritos)}) -> {destino}")
            resumen["descargados"] += 1

    return resumen


def main() -> int:
    parser = argparse.ArgumentParser(
        description=f"Descarga los datos de taxis de {ANIO} del NYC TLC."
    )
    parser.add_argument(
        "--taxi",
        choices=(*TIPOS_TAXI, "all"),
        default="all",
        help="tipo de taxi a descargar (por defecto: all)",
    )
    argumentos = parser.parse_args()
    tipos = TIPOS_TAXI if argumentos.taxi == "all" else (argumentos.taxi,)

    total = {"descargados": 0, "omitidos": 0, "no_publicados": [], "fallidos": []}
    for tipo in tipos:
        resumen = descargar(tipo)
        total["descargados"] += resumen["descargados"]
        total["omitidos"] += resumen["omitidos"]
        total["no_publicados"] += [f"{tipo} {mes}" for mes in resumen["no_publicados"]]
        total["fallidos"] += [f"{tipo} {mes}" for mes in resumen["fallidos"]]

    print("\n" + "=" * 60)
    print("RESUMEN")
    print("=" * 60)
    print(f"  descargados   : {total['descargados']}")
    print(f"  ya existian   : {total['omitidos']}")
    print(f"  no publicados : {len(total['no_publicados'])}")
    if total["no_publicados"]:
        print(f"      {', '.join(total['no_publicados'])}")
    print(f"  fallidos      : {len(total['fallidos'])}")
    if total["fallidos"]:
        print(f"      {', '.join(total['fallidos'])}")
    print("=" * 60)

    return 1 if total["fallidos"] else 0


if __name__ == "__main__":
    sys.exit(main())
