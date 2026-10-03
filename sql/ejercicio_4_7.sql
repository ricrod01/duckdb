WITH viajes AS (
    SELECT
        'yellow' AS taxi_type,
        pep_pickup_datetime,
        pep_dropoff_datetime,
        trip_distance,
        total_amount
    FROM read_parquet('../data/processed/yellow_2026.parquet')
    UNION ALL
    SELECT
        'green' AS taxi_type,
        pep_pickup_datetime,
        pep_dropoff_datetime,
        trip_distance,
        total_amount
    FROM read_parquet('../data/processed/green_2026.parquet')
), metricas AS (
    SELECT
        *,
        date_diff('second', pep_pickup_datetime, pep_dropoff_datetime) / 3600.0 AS duration_hours
    FROM viajes
)
SELECT
    taxi_type,
    COUNT(*) AS trips,
    COUNT(*) FILTER (
        WHERE pep_pickup_datetime < DATE '2026-01-01'
           OR pep_pickup_datetime >= DATE '2027-01-01'
    ) AS pickup_outside_2026,
    COUNT(*) FILTER (WHERE trip_distance <= 0) AS non_positive_distance,
    COUNT(*) FILTER (WHERE trip_distance > 100) AS distance_over_100_miles,
    COUNT(*) FILTER (WHERE duration_hours = 0) AS zero_duration,
    COUNT(*) FILTER (WHERE duration_hours > 4) AS duration_over_4_hours,
    COUNT(*) FILTER (WHERE total_amount > 500) AS total_over_500,
    COUNT(*) FILTER (
        WHERE duration_hours > 0 AND trip_distance / duration_hours > 100
    ) AS speed_over_100_mph,
    ROUND(100.0 * COUNT(*) FILTER (
        WHERE (pep_pickup_datetime < DATE '2026-01-01'
           OR pep_pickup_datetime >= DATE '2027-01-01')
           OR trip_distance <= 0
           OR trip_distance > 100
           OR duration_hours = 0
           OR duration_hours > 4
           OR total_amount > 500
           OR (duration_hours > 0 AND trip_distance / duration_hours > 100)
    ) / COUNT(*), 4) AS pct_with_quality_flag
FROM metricas
GROUP BY taxi_type
ORDER BY taxi_type;
