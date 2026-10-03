WITH viajes AS (
    SELECT
        'yellow' AS taxi_type,
        pep_pickup_datetime,
        pep_dropoff_datetime,
        trip_distance,
        passenger_count,
        total_amount
    FROM read_parquet('../data/processed/yellow_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
    UNION ALL
    SELECT
        'green' AS taxi_type,
        pep_pickup_datetime,
        pep_dropoff_datetime,
        trip_distance,
        passenger_count,
        total_amount
    FROM read_parquet('../data/processed/green_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
), metricas AS (
    SELECT
        taxi_type,
        trip_distance,
        passenger_count,
        total_amount,
        date_diff('second', pep_pickup_datetime, pep_dropoff_datetime) / 60.0 AS duration_minutes
    FROM viajes
)
SELECT
    taxi_type,
    COUNT(*) AS trips,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(quantile_cont(trip_distance, 0.5), 2) AS median_distance,
    ROUND(quantile_cont(trip_distance, 0.9), 2) AS p90_distance,
    ROUND(AVG(duration_minutes), 2) AS avg_duration_minutes,
    ROUND(quantile_cont(duration_minutes, 0.5), 2) AS median_duration_minutes,
    ROUND(AVG(passenger_count), 2) AS avg_passengers,
    ROUND(AVG(total_amount), 2) AS avg_total_amount,
    ROUND(quantile_cont(total_amount, 0.5), 2) AS median_total_amount
FROM metricas
GROUP BY taxi_type
ORDER BY taxi_type;
