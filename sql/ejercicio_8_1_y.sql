WITH datos AS (
    SELECT * FROM read_parquet('../data/raw/yellow/2025/*.parquet', union_by_name = true)
), modas AS (
    SELECT mode(store_and_fwd_flag) AS moda_store_and_fwd_flag FROM datos
)
SELECT
    VendorID,
    tpep_pickup_datetime AS pep_pickup_datetime,
    tpep_dropoff_datetime AS pep_dropoff_datetime,
    coalesce(store_and_fwd_flag, moda_store_and_fwd_flag) AS store_and_fwd_flag,
    coalesce(RatecodeID, 99) AS RatecodeID,
    PULocationID,
    DOLocationID,
    CASE WHEN passenger_count IS NULL OR passenger_count = 0 THEN 1 ELSE passenger_count END
        AS passenger_count,
    trip_distance, fare_amount, extra, mta_tax, tip_amount, tolls_amount,
    improvement_surcharge,
    coalesce(congestion_surcharge, 0) AS congestion_surcharge,
    coalesce(cbd_congestion_fee, 0)::DOUBLE AS cbd_congestion_fee,
    total_amount, payment_type,
    coalesce(Airport_fee, 0) AS Airport_fee
FROM datos CROSS JOIN modas
WHERE total_amount >= 0
  AND tpep_pickup_datetime >= TIMESTAMP '2025-01-01'
  AND tpep_pickup_datetime < TIMESTAMP '2026-01-01'
  AND tpep_dropoff_datetime >= tpep_pickup_datetime;
