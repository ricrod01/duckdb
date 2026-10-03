SELECT
MODE(store_and_fwd_flag) AS store_and_fwd_flag_mode,
MIN(passenger_count) AS passenger_count_min,
AVG(passenger_count) AS passenger_count_avg,
MAX(passenger_count) AS passenger_count_max,
MIN(Airport_fee) AS Airport_fee_min,
AVG(Airport_fee) AS Airport_fee_avg,
MAX(Airport_fee) AS Airport_fee_max,
MIN(congestion_surcharge) AS congestion_surcharge_min,
AVG(congestion_surcharge) AS congestion_surcharge_avg,
MAX(congestion_surcharge) AS congestion_surcharge_max
FROM read_parquet('../data/raw/yellow/2026/*.parquet')