WITH inventario AS (
    SELECT 'yellow' AS taxi_type, 2024 AS data_year, filename
    FROM read_parquet('../data/raw/yellow/2024/*.parquet', filename = true)
    UNION ALL
    SELECT 'green' AS taxi_type, 2024 AS data_year, filename
    FROM read_parquet('../data/raw/green/2024/*.parquet', filename = true)
    UNION ALL
    SELECT 'yellow' AS taxi_type, 2026 AS data_year, filename
    FROM read_parquet('../data/raw/yellow/2026/*.parquet', filename = true)
    UNION ALL
    SELECT 'green' AS taxi_type, 2026 AS data_year, filename
    FROM read_parquet('../data/raw/green/2026/*.parquet', filename = true)
)
SELECT
    data_year,
    taxi_type,
    COUNT(DISTINCT filename) AS files,
    COUNT(*) AS raw_rows
FROM inventario
GROUP BY data_year, taxi_type
ORDER BY data_year, taxi_type;
