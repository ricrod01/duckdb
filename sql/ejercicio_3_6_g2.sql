SELECT
COUNT(*) FILTER (WHERE total_amount < 0) AS total_amount_negativa,
COUNT(*) FILTER (WHERE trip_distance < 0) AS trip_distance_negativa,
COUNT(*) FILTER (WHERE passenger_count < 0) AS passenger_count_negativo,
COUNT(*) FILTER (WHERE lpep_dropoff_datetime < lpep_pickup_datetime) AS fechas_inconsistentes
FROM read_parquet('../data/raw/green/2026/*.parquet')