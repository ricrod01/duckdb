SELECT MAX(total_amount)
FROM read_parquet('../data/raw/yellow/2026/*.parquet')
WHERE Airport_fee < 0
    OR congestion_surchaRge < 0