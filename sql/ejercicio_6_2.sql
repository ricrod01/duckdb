-- Q1: caracteristicas de los viajes por anio y tipo de taxi.
-- El script sustituye SOURCE y YEAR_FILTER por fuentes equivalentes.
SELECT
    data_year,
    taxi_type,
    COUNT(*) AS trips,
    ROUND(AVG(trip_distance), 4) AS avg_distance,
    ROUND(quantile_cont(trip_distance, 0.5), 4) AS median_distance,
    ROUND(quantile_cont(trip_distance, 0.9), 4) AS p90_distance,
    ROUND(AVG(total_amount), 4) AS avg_total_amount
FROM {{SOURCE}}
WHERE {{YEAR_FILTER}}
GROUP BY data_year, taxi_type
ORDER BY data_year, taxi_type;
