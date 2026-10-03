-- Q2: comportamiento temporal mensual.
-- El script sustituye SOURCE y YEAR_FILTER por fuentes equivalentes.
SELECT
    data_year,
    EXTRACT(month FROM pep_pickup_datetime)::INTEGER AS month,
    taxi_type,
    COUNT(*) AS trips,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 4) AS avg_total_amount
FROM {{SOURCE}}
WHERE {{YEAR_FILTER}}
GROUP BY data_year, month, taxi_type
ORDER BY data_year, month, taxi_type;
