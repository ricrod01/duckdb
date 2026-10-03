WITH viajes AS (
    SELECT 'yellow' AS taxi_type, PULocationID
    FROM read_parquet('../data/processed/yellow_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
    UNION ALL
    SELECT 'green' AS taxi_type, PULocationID
    FROM read_parquet('../data/processed/green_2026.parquet')
    WHERE pep_pickup_datetime >= DATE '2026-01-01'
      AND pep_pickup_datetime < DATE '2027-01-01'
), zonas AS (
    SELECT taxi_type, PULocationID, COUNT(*) AS trips
    FROM viajes
    GROUP BY taxi_type, PULocationID
), ranking AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY taxi_type ORDER BY trips DESC, PULocationID) AS position,
        ROUND(100.0 * trips / SUM(trips) OVER (PARTITION BY taxi_type), 2) AS pct_trips
    FROM zonas
)
SELECT taxi_type, position, PULocationID, trips, pct_trips
FROM ranking
WHERE position <= 10
ORDER BY taxi_type, position;
