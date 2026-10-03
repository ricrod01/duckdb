WITH viajes AS (
    SELECT 'yellow' AS taxi_type, pep_pickup_datetime, total_amount
    FROM read_parquet('../data/processed/yellow_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
    UNION ALL
    SELECT 'green' AS taxi_type, pep_pickup_datetime, total_amount
    FROM read_parquet('../data/processed/green_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
)
SELECT
    date_trunc('month', pep_pickup_datetime)::DATE AS month,
    taxi_type,
    COUNT(*) AS trips,
    ROUND(AVG(total_amount), 2) AS avg_total_amount,
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM viajes
GROUP BY month, taxi_type
ORDER BY month, taxi_type;
