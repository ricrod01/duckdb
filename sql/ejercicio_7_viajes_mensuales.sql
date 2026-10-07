SELECT
    periodo,
    tipo_taxi,
    count(*) AS viajes,
    sum(total_amount) AS ingresos
FROM viajes_analiticos
WHERE es_valido
GROUP BY periodo, tipo_taxi
ORDER BY periodo, tipo_taxi;