-- Indicadores anuales sobre registros que cumplen las reglas de calidad del Ejercicio 7.
SELECT
    anio AS data_year,
    tipo_taxi AS taxi_type,
    count(*) AS viajes,
    round(sum(total_amount), 2) AS ingresos,
    round(avg(total_amount), 2) AS ticket_medio,
    round(median(total_amount), 2) AS ticket_mediano,
    round(avg(trip_distance), 2) AS distancia_media,
    round(median(trip_distance), 2) AS distancia_mediana,
    round(avg(duracion_minutos), 2) AS duracion_media,
    round(avg(tip_amount) FILTER (WHERE payment_type = 1 AND tip_amount >= 0), 2)
        AS propina_media_tarjeta
FROM viajes_analiticos
WHERE es_valido AND anio IN (2024, 2025, 2026)
GROUP BY anio, tipo_taxi
ORDER BY anio, tipo_taxi;
