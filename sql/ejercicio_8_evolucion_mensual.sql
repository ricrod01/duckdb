-- Serie mensual de volumen, ingresos y ticket mediano.
SELECT
    periodo,
    anio AS data_year,
    mes,
    tipo_taxi AS taxi_type,
    count(*) AS viajes,
    round(sum(total_amount), 2) AS ingresos,
    round(median(total_amount), 2) AS ticket_mediano,
    round(median(trip_distance), 2) AS distancia_mediana
FROM viajes_analiticos
WHERE es_valido AND anio IN (2024, 2025, 2026)
GROUP BY periodo, anio, mes, tipo_taxi
ORDER BY periodo, tipo_taxi;
