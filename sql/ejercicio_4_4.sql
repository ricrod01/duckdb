WITH viajes AS (
    SELECT 'yellow' AS taxi_type, payment_type
    FROM read_parquet('../data/processed/yellow_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
    UNION ALL
    SELECT 'green' AS taxi_type, payment_type
    FROM read_parquet('../data/processed/green_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
), pagos AS (
    SELECT
        taxi_type,
        payment_type,
        CASE payment_type
            WHEN 0 THEN 'Flex Fare'
            WHEN 1 THEN 'Credit card'
            WHEN 2 THEN 'Cash'
            WHEN 3 THEN 'No charge'
            WHEN 4 THEN 'Dispute'
            WHEN 5 THEN 'Unknown'
            WHEN 6 THEN 'Voided trip'
            ELSE 'Missing/other'
        END AS payment_method,
        COUNT(*) AS trips
    FROM viajes
    GROUP BY taxi_type, payment_type
)
SELECT
    taxi_type,
    payment_type,
    payment_method,
    trips,
    ROUND(100.0 * trips / SUM(trips) OVER (PARTITION BY taxi_type), 2) AS pct_trips
FROM pagos
ORDER BY taxi_type, trips DESC;
