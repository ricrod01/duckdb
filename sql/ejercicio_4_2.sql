WITH viajes AS (
    SELECT 'yellow' AS taxi_type, pep_pickup_datetime
    FROM read_parquet('../data/processed/yellow_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
    UNION ALL
    SELECT 'green' AS taxi_type, pep_pickup_datetime
    FROM read_parquet('../data/processed/green_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
), por_hora AS (
    SELECT
        taxi_type,
        EXTRACT(hour FROM pep_pickup_datetime)::INTEGER AS pickup_hour,
        COUNT(*) AS trips
    FROM viajes
    GROUP BY taxi_type, pickup_hour
)
SELECT
    taxi_type,
    pickup_hour,
    trips,
    ROUND(100.0 * trips / SUM(trips) OVER (PARTITION BY taxi_type), 2) AS pct_trips
FROM por_hora
ORDER BY taxi_type, pickup_hour;
