-- Cobertura efectiva por anio y tipo de taxi; evita tratar 2026 parcial como completo.
SELECT
    data_year,
    taxi_type,
    count(DISTINCT month(pep_pickup_datetime)) AS meses_disponibles,
    min(pep_pickup_datetime)::DATE AS primera_fecha,
    max(pep_pickup_datetime)::DATE AS ultima_fecha,
    count(*) AS registros
FROM trips
GROUP BY data_year, taxi_type
ORDER BY data_year, taxi_type;
