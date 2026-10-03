# Lab 8 - DuckDB

Repositorio base del laboratorio 8 del curso **CC3084 - Data Science**
(Universidad del Valle de Guatemala, Ciclo 2, 2026).

Este es el repositorio **proporcionado por el docente**. Contiene la estructura
del proyecto, el ambiente de ejecucion basado en Docker y un script que descarga
los datos de **2026**. Todo lo demas debe ser construido por cada equipo.

## Trabajo con fork

El laboratorio se desarrolla y se entrega sobre un **fork** de este repositorio.
No se trabaja directamente sobre el repositorio del docente.

1. Realice un fork de este repositorio:
   <https://github.com/menene/duckdb>

2. Clone **su propio fork** (no el del docente):

   ```bash
   git clone https://github.com/<su-usuario>/duckdb.git
   cd duckdb
   ```

3. Opcional, para recibir correcciones publicadas por el docente:

   ```bash
   git remote add upstream https://github.com/menene/duckdb.git
   git fetch upstream
   ```

Realice commits frecuentes y descriptivos: el historial del repositorio es parte
de la evaluacion. **La entrega del laboratorio es la URL de su fork.**

## Estructura

```text
duckdb/
|
+-- data/
|   +-- raw/
|   +-- processed/
|
+-- notebooks/
|
+-- scripts/
|
+-- sql/
|
+-- docs/
|
+-- Dockerfile
+-- metabase.Dockerfile
+-- docker-compose.yml
+-- README.md
```

## Requisitos

- Docker, con Docker Compose
- Git

La primera construccion del ambiente descarga varios cientos de MB y puede
tardar algunos minutos.

Considere el espacio en disco: las imagenes de Docker ocupan unos 3 GB y los
datos de los tres anios del laboratorio superan 1.5 GB, a los que se suma la
base materializada del Ejercicio 6. Se recomienda tener al menos 10 GB libres.

## Datos

El repositorio incluye `scripts/download_data.py`, que descarga los archivos de
2026 publicados por la TLC (`--help` muestra las opciones disponibles). Los
archivos se guardan en `data/raw/<tipo>/<anio>/`.

La TLC publica cada mes con varias semanas de atraso, por lo que los ultimos
meses de 2026 todavia no existen. El script consulta al servidor que meses estan
publicados, de modo que vuelve a ejecutarse sin problema conforme aparezcan
nuevos archivos.

Los datos descargados **no deben incluirse en el repositorio Git**. El archivo
`.gitignore` ya esta configurado para evitarlo.

Fuente de datos: NYC TLC Trip Record Data
<https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page>

Dentro de los contenedores, la carpeta `data/` del proyecto esta montada en
`/workspace/data`. Esa es la ruta que deben usar las herramientas que corren
dentro del ambiente, no la ruta de su computadora.

> **Nota sobre DuckDB:** un archivo `.duckdb` admite un solo proceso con permiso
> de escritura a la vez. Si conecta una herramienta externa a su base de datos,
> use el modo de solo lectura (`read_only`) en esa conexion; de lo contrario los
> demas procesos no podran abrir el archivo.

## Material a entregar

Al finalizar, su fork debe contener:

- el codigo fuente modificado y los scripts de descarga;
- las consultas SQL desarrolladas;
- el notebook o notebooks utilizados;
- la documentacion de las consultas;
- los scripts utilizados para los benchmarks;
- el codigo de los indicadores y visualizaciones;
- el tablero o la evidencia del tablero desarrollado;
- este `README.md`, completado segun la siguiente seccion.

Los archivos de datos descargados **no** deben incluirse.

---

# Documentacion del equipo

Las siguientes secciones deben ser completadas por cada equipo. El README final
debe permitir que una persona que no participo en el desarrollo pueda levantar el
ambiente, descargar los datos, ejecutar el analisis, reproducir los benchmarks y
generar los resultados principales.

## Como levantar el ambiente

<!-- TODO (Ejercicio 1.5) -->

El proyecto cuenta con una imagen que permite construir el ambiente mediante Docker Compose.

Desde la raíz del repositorio se debe ejecutar:

```bash
docker compose up -d
```

Este comando construye las imágenes y levanta los servicios que están definidos en el archivo docker-compose.yml.
Una vez iniciado el ambiente, JupyterLab estará disponible en el puerto 8888 y Metabase en el puerto 3000

Para dar de baja los servicios, se debe ejecutar:

```bash
docker compose down
```

## Como descargar los datos

Desde la raiz del repositorio, descargue primero los datos disponibles de 2026:

```bash
python scripts/download_data.py
```

Para incorporar los doce meses de 2024 sin modificar ni reemplazar los datos de
2026, ejecute el descargador del Ejercicio 5:

```bash
python scripts/download_data_ejercicio_5.py
```

Ambos scripts descargan Yellow y Green Taxi, guardan los archivos en
`data/raw/<tipo>/<anio>/` y omiten cualquier archivo local no vacio. Se puede
usar `--taxi yellow` o `--taxi green` para descargar solo un tipo. Los datos
quedan excluidos de Git mediante `.gitignore`.

<!-- TODO: agregar aqui el descargador de 2025 en el Ejercicio 8. -->

## Como ejecutar el analisis

Con el ambiente levantado, abra JupyterLab en <http://127.0.0.1:8888> y ejecute
los cuadernos en este orden:

1. `notebooks/ejercicio_3.ipynb`: explora y genera los Parquet procesados de 2026.
2. `notebooks/ejercicio_4.ipynb`: realiza el analisis exploratorio de 2026.
3. `notebooks/ejercicio_5.ipynb`: genera los procesados de 2024 y valida la
   consulta conjunta de 2024 y 2026.
4. `notebooks/ejercicio_6.ipynb`: presenta y analiza el benchmark entre Parquet
   y una tabla materializada en DuckDB.

Las consultas ejecutadas por los cuadernos estan versionadas en `sql/`. Los
Parquet derivados se escriben en `data/processed/` y no se incluyen en Git.

## Como reproducir los benchmarks

Despues de ejecutar los cuadernos 3 y 5, ejecute desde la raiz:

```bash
python scripts/benchmark_ejercicio_6.py --repetitions 3
```

El script crea `data/processed/ejercicio_6.duckdb`, verifica que cada consulta
produzca el mismo resultado sobre Parquet y sobre la tabla `trips`, y evalua
tres cantidades de datos: 2026 parcial, 2024 completo y ambos años. Los tiempos
crudos se guardan en `docs/benchmark_ejercicio_6.csv`; el cuaderno
`notebooks/ejercicio_6.ipynb` genera la tabla resumen, visualizaciones y
discusion. La base materializada es un artefacto regenerable y no se incluye en
Git.

## Como generar los resultados principales

<!-- TODO -->
