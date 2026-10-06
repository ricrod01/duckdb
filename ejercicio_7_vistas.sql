CREATE OR REPLACE VIEW viajes_base AS
SELECT
    CASE
        WHEN lower(filename) LIKE '%yellow_tripdata_%' THEN 'yellow'
        WHEN lower(filename) LIKE '%green_tripdata_%'  THEN 'green'
        ELSE 'unknown'
    END AS tipo_taxi,

    coalesce(
        tpep_pickup_datetime,
        lpep_pickup_datetime
    )::TIMESTAMP AS pickup_datetime,

    coalesce(
        tpep_dropoff_datetime,
        lpep_dropoff_datetime
    )::TIMESTAMP AS dropoff_datetime,

    passenger_count::DOUBLE AS passenger_count,
    trip_distance::DOUBLE AS trip_distance,
    payment_type::INTEGER AS payment_type,
    fare_amount::DOUBLE AS fare_amount,
    tip_amount::DOUBLE AS tip_amount,
    tolls_amount::DOUBLE AS tolls_amount,
    total_amount::DOUBLE AS total_amount,
    PULocationID::INTEGER AS pickup_location_id,
    DOLocationID::INTEGER AS dropoff_location_id,
    filename AS archivo_origen

FROM read_parquet(
    'data/raw/**/*.parquet',
    union_by_name = true,
    filename = true
);

CREATE OR REPLACE VIEW viajes_analiticos AS
SELECT
    *,
    year(pickup_datetime) AS anio,
    month(pickup_datetime) AS mes,
    date_trunc('month', pickup_datetime) AS periodo,
    hour(pickup_datetime) AS hora,
    dayname(pickup_datetime) AS dia_semana,

    date_diff(
        'second',
        pickup_datetime,
        dropoff_datetime
    ) / 60.0 AS duracion_minutos,

    CASE
        WHEN payment_type = 1 THEN 'Tarjeta'
        WHEN payment_type = 2 THEN 'Efectivo'
        WHEN payment_type = 3 THEN 'Sin cobro'
        WHEN payment_type = 4 THEN 'Disputa'
        WHEN payment_type = 5 THEN 'Desconocido'
        WHEN payment_type = 6 THEN 'Viaje anulado'
        ELSE 'No informado'
    END AS forma_pago,

    CASE
        WHEN pickup_datetime IS NULL THEN FALSE
        WHEN dropoff_datetime IS NULL THEN FALSE
        WHEN dropoff_datetime <= pickup_datetime THEN FALSE
        WHEN trip_distance < 0 OR trip_distance > 200 THEN FALSE
        WHEN total_amount < 0 OR total_amount > 1000 THEN FALSE
        WHEN date_diff(
            'minute',
            pickup_datetime,
            dropoff_datetime
        ) > 360 THEN FALSE
        ELSE TRUE
    END AS es_valido

FROM viajes_base;