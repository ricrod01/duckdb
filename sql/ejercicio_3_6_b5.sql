SELECT MAX(total_amount)
FROM read_parquet('../data/raw/green/2026/*.parquet')
WHERE congestion_surchaRge < 0