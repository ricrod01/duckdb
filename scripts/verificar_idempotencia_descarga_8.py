#!/usr/bin/env python3
"""Prueba sin red que los archivos existentes de 2025 nunca se descargan otra vez."""

import tempfile
from pathlib import Path
import sys
from types import SimpleNamespace

# La prueba no usa red; este sustituto permite ejecutarla incluso fuera del
# contenedor antes de instalar requirements.txt.
sys.modules.setdefault("requests", SimpleNamespace())
import download_data_ejercicio_8 as descarga


def prohibido(*_args, **_kwargs):
    raise AssertionError("se intento acceder a la red para un archivo ya existente")


def main() -> int:
    with tempfile.TemporaryDirectory() as temporal:
        descarga.DIR_DESTINO = Path(temporal)
        descarga.esta_publicado = prohibido
        descarga.descargar_archivo = prohibido
        for taxi in descarga.TIPOS_TAXI:
            for mes in range(1, 13):
                ruta = descarga.ruta_destino(taxi, mes)
                ruta.parent.mkdir(parents=True, exist_ok=True)
                ruta.write_bytes(b"parquet-existente")
            resumen = descarga.descargar(taxi)
            assert resumen["omitidos"] == 12
            assert resumen["descargados"] == 0
            assert not resumen["fallidos"]
    print("OK: 24 archivos existentes fueron omitidos sin acceso a la red.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
