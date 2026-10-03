WITH viajes AS (
    SELECT 'yellow' AS taxi_type, payment_type, fare_amount, tip_amount
    FROM read_parquet('../data/processed/yellow_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
    UNION ALL
    SELECT 'green' AS taxi_type, payment_type, fare_amount, tip_amount
    FROM read_parquet('../data/processed/green_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
)
SELECT
    taxi_type,
    COUNT(*) AS card_trips,
    COUNT(*) FILTER (WHERE tip_amount > 0) AS card_trips_with_tip,
    ROUND(100.0 * COUNT(*) FILTER (WHERE tip_amount > 0) / COUNT(*), 2) AS pct_card_trips_with_tip,
    ROUND(AVG(tip_amount), 2) AS avg_tip,
    ROUND(quantile_cont(tip_amount, 0.5), 2) AS median_tip,
    ROUND(AVG(100.0 * tip_amount / NULLIF(fare_amount, 0)), 2) AS avg_tip_pct_of_fare
FROM viajes
WHERE payment_type = 1
GROUP BY taxi_type
ORDER BY taxi_type;
