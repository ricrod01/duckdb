WITH viajes AS (
    SELECT 2024 AS data_year, 'yellow' AS taxi_type, pep_pickup_datetime
    FROM read_parquet('../data/processed/yellow_2024.parquet')
    UNION ALL
    SELECT 2024 AS data_year, 'green' AS taxi_type, pep_pickup_datetime
    FROM read_parquet('../data/processed/green_2024.parquet')
    UNION ALL
    SELECT 2026 AS data_year, 'yellow' AS taxi_type, pep_pickup_datetime
    FROM read_parquet('../data/processed/yellow_2026.parquet')
    UNION ALL
    SELECT 2026 AS data_year, 'green' AS taxi_type, pep_pickup_datetime
    FROM read_parquet('../data/processed/green_2026.parquet')
)
SELECT
    data_year,
    taxi_type,
    COUNT(*) AS processed_rows,
    COUNT(*) FILTER (
        WHERE EXTRACT(year FROM pep_pickup_datetime) <> data_year
    ) AS pickup_outside_expected_year
FROM viajes
GROUP BY data_year, taxi_type
ORDER BY data_year, taxi_type;
