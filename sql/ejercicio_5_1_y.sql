WITH datos AS (
    SELECT *
    FROM read_parquet('../data/raw/yellow/2024/*.parquet')
), modas AS (
    SELECT mode(store_and_fwd_flag) AS moda_store_and_fwd_flag
    FROM datos
)
SELECT
    VendorID,
    tpep_pickup_datetime AS pep_pickup_datetime,
    tpep_dropoff_datetime AS pep_dropoff_datetime,
    COALESCE(store_and_fwd_flag, moda_store_and_fwd_flag) AS store_and_fwd_flag,
    COALESCE(RatecodeID, 99) AS RatecodeID,
    PULocationID,
    DOLocationID,
    CASE
        WHEN passenger_count IS NULL OR passenger_count = 0 THEN 1
        ELSE passenger_count
    END AS passenger_count,
    trip_distance,
    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    COALESCE(congestion_surcharge, 0) AS congestion_surcharge,
    NULL::DOUBLE AS cbd_congestion_fee,
    total_amount,
    payment_type,
    COALESCE(Airport_fee, 0) AS Airport_fee
FROM datos
CROSS JOIN modas
WHERE total_amount >= 0
  AND tpep_dropoff_datetime >= tpep_pickup_datetime;
