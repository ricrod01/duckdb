WITH viajes AS (
    SELECT 'yellow' AS taxi_type, trip_distance
    FROM read_parquet('../data/processed/yellow_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
    UNION ALL
    SELECT 'green' AS taxi_type, trip_distance
    FROM read_parquet('../data/processed/green_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
), distribucion AS (
    SELECT
        taxi_type,
        CASE
            WHEN trip_distance <= 0 THEN '0. Non-positive'
            WHEN trip_distance <= 1 THEN '1. (0, 1]'
            WHEN trip_distance <= 3 THEN '2. (1, 3]'
            WHEN trip_distance <= 5 THEN '3. (3, 5]'
            WHEN trip_distance <= 10 THEN '4. (5, 10]'
            WHEN trip_distance <= 25 THEN '5. (10, 25]'
            ELSE '6. More than 25'
        END AS distance_range,
        COUNT(*) AS trips
    FROM viajes
    GROUP BY taxi_type, distance_range
)
SELECT
    taxi_type,
    distance_range,
    trips,
    ROUND(100.0 * trips / SUM(trips) OVER (PARTITION BY taxi_type), 2) AS pct_trips
FROM distribucion
ORDER BY taxi_type, distance_range;
