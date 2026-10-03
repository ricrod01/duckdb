-- Q3: distribucion de medios de pago y propinas.
-- El script sustituye SOURCE y YEAR_FILTER por fuentes equivalentes.
SELECT
    data_year,
    taxi_type,
    payment_type,
    COUNT(*) AS trips,
    ROUND(AVG(tip_amount), 4) AS avg_tip,
    ROUND(SUM(tip_amount), 2) AS total_tips
FROM {{SOURCE}}
WHERE {{YEAR_FILTER}}
GROUP BY data_year, taxi_type, payment_type
ORDER BY data_year, taxi_type, payment_type;
