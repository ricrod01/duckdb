-- Capa semantica del tablero construida sobre la tabla materializada del Ejercicio 6.
-- Asi no depende del directorio de trabajo ni vuelve a escanear los Parquet crudos.
CREATE OR REPLACE VIEW viajes_base AS
SELECT
    data_year::INTEGER AS anio_datos,
    taxi_type::VARCHAR AS tipo_taxi,
    pep_pickup_datetime::TIMESTAMP AS pickup_datetime,
    pep_dropoff_datetime::TIMESTAMP AS dropoff_datetime,
    passenger_count::DOUBLE AS passenger_count,
    trip_distance::DOUBLE AS trip_distance,
    payment_type::INTEGER AS payment_type,
    fare_amount::DOUBLE AS fare_amount,
    tip_amount::DOUBLE AS tip_amount,
    total_amount::DOUBLE AS total_amount,
    PULocationID::INTEGER AS pickup_location_id,
    DOLocationID::INTEGER AS dropoff_location_id
FROM trips;

CREATE OR REPLACE VIEW viajes_analiticos AS
WITH derivados AS (
    SELECT
        *,
        year(pickup_datetime)::INTEGER AS anio,
        month(pickup_datetime)::INTEGER AS mes,
        date_trunc('month', pickup_datetime)::DATE AS periodo,
        hour(pickup_datetime)::INTEGER AS hora,
        isodow(pickup_datetime)::INTEGER AS dia_semana_num,
        date_diff('second', pickup_datetime, dropoff_datetime) / 60.0
            AS duracion_minutos
    FROM viajes_base
)
SELECT
    *,
    CASE dia_semana_num
        WHEN 1 THEN 'Lunes' WHEN 2 THEN 'Martes' WHEN 3 THEN 'Miercoles'
        WHEN 4 THEN 'Jueves' WHEN 5 THEN 'Viernes' WHEN 6 THEN 'Sabado'
        WHEN 7 THEN 'Domingo'
    END AS dia_semana,
    CASE
        WHEN payment_type = 1 THEN 'Tarjeta'
        WHEN payment_type = 2 THEN 'Efectivo'
        WHEN payment_type = 3 THEN 'Sin cobro'
        WHEN payment_type = 4 THEN 'Disputa'
        WHEN payment_type = 5 THEN 'Desconocido'
        WHEN payment_type = 6 THEN 'Viaje anulado'
        ELSE 'No informado'
    END AS forma_pago,

    pickup_datetime IS NOT NULL
        AND dropoff_datetime IS NOT NULL
        AND trip_distance IS NOT NULL
        AND total_amount IS NOT NULL
        AND dropoff_datetime > pickup_datetime
        AND trip_distance BETWEEN 0 AND 200
        AND total_amount BETWEEN 0 AND 1000
        AND duracion_minutos BETWEEN 0 AND 360 AS es_valido
FROM derivados;
