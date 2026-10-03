WITH viajes AS (
    SELECT
        2024 AS data_year,
        'yellow' AS taxi_type,
        pep_pickup_datetime,
        trip_distance,
        total_amount
    FROM read_parquet('../data/processed/yellow_2024.parquet')
    WHERE pep_pickup_datetime >= DATE '2024-01-01'
      AND pep_pickup_datetime < DATE '2025-01-01'
    UNION ALL
    SELECT
        2024 AS data_year,
        'green' AS taxi_type,
        pep_pickup_datetime,
        trip_distance,
        total_amount
    FROM read_parquet('../data/processed/green_2024.parquet')
    WHERE pep_pickup_datetime >= DATE '2024-01-01'
      AND pep_pickup_datetime < DATE '2025-01-01'
    UNION ALL
    SELECT
        2026 AS data_year,
        'yellow' AS taxi_type,
        pep_pickup_datetime,
        trip_distance,
        total_amount
    FROM read_parquet('../data/processed/yellow_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
    UNION ALL
    SELECT
        2026 AS data_year,
        'green' AS taxi_type,
        pep_pickup_datetime,
        trip_distance,
        total_amount
    FROM read_parquet('../data/processed/green_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
)
SELECT
    data_year,
    EXTRACT(month FROM pep_pickup_datetime)::INTEGER AS month,
    taxi_type,
    COUNT(*) AS trips,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(AVG(total_amount), 2) AS avg_total_amount
FROM viajes
GROUP BY data_year, month, taxi_type
ORDER BY data_year, month, taxi_type;
