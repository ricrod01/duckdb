SELECT
COUNT(*) AS conteo,
MIN(total_amount) AS total_amount_min,
AVG(total_amount) AS total_amount_avg,
MAX(total_amount) AS total_amount_max,
MIN(trip_distance) AS trip_distance_min,
AVG(trip_distance) AS trip_distance_avg,
MAX(trip_distance) AS trip_distance_max
FROM read_parquet('../data/raw/green/2026/*.parquet')
WHERE (passenger_count IS NULL
    OR passenger_count = 0)
    AND total_amount > 0