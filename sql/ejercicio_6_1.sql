CREATE OR REPLACE TABLE trips AS
SELECT
    2024 AS data_year,
    'yellow' AS taxi_type,
    pep_pickup_datetime,
    pep_dropoff_datetime,
    passenger_count,
    trip_distance,
    PULocationID,
    DOLocationID,
    payment_type,
    fare_amount,
    tip_amount,
    total_amount
FROM read_parquet('../data/processed/yellow_2024.parquet')
WHERE pep_pickup_datetime >= DATE '2024-01-01'
  AND pep_pickup_datetime < DATE '2025-01-01'
UNION ALL
SELECT
    2024 AS data_year,
    'green' AS taxi_type,
    pep_pickup_datetime,
    pep_dropoff_datetime,
    passenger_count,
    trip_distance,
    PULocationID,
    DOLocationID,
    payment_type,
    fare_amount,
    tip_amount,
    total_amount
FROM read_parquet('../data/processed/green_2024.parquet')
WHERE pep_pickup_datetime >= DATE '2024-01-01'
  AND pep_pickup_datetime < DATE '2025-01-01'
UNION ALL
SELECT
    2026 AS data_year,
    'yellow' AS taxi_type,
    pep_pickup_datetime,
    pep_dropoff_datetime,
    passenger_count,
    trip_distance,
    PULocationID,
    DOLocationID,
    payment_type,
    fare_amount,
    tip_amount,
    total_amount
FROM read_parquet('../data/processed/yellow_2026.parquet')
WHERE pep_pickup_datetime >= DATE '2026-01-01'
  AND pep_pickup_datetime < DATE '2027-01-01'
UNION ALL
SELECT
    2026 AS data_year,
    'green' AS taxi_type,
    pep_pickup_datetime,
    pep_dropoff_datetime,
    passenger_count,
    trip_distance,
    PULocationID,
    DOLocationID,
    payment_type,
    fare_amount,
    tip_amount,
    total_amount
FROM read_parquet('../data/processed/green_2026.parquet')
WHERE pep_pickup_datetime >= DATE '2026-01-01'
  AND pep_pickup_datetime < DATE '2027-01-01';
