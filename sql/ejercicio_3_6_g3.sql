SELECT
MODE(store_and_fwd_flag) AS store_and_fwd_flag_mode,
MODE(trip_type) AS trip_type_mode,
MODE(payment_type) AS payment_type_mode,
MIN(passenger_count) AS passenger_count_min,
AVG(passenger_count) AS passenger_count_avg,
MAX(passenger_count) AS passenger_count_max,
MIN(congestion_surcharge) AS congestion_surcharge_min,
AVG(congestion_surcharge) AS congestion_surcharge_avg,
MAX(congestion_surcharge) AS congestion_surcharge_max
FROM read_parquet('../data/raw/green/2026/*.parquet')