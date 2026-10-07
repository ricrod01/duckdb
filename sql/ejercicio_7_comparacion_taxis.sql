SELECT
    tipo_taxi,
    count(*) AS viajes,
    avg(trip_distance) AS distancia_media,
    median(trip_distance) AS distancia_mediana,
    avg(duracion_minutos) AS duracion_media,
    avg(total_amount) AS importe_medio,
    median(total_amount) AS importe_mediano
FROM viajes_analiticos
WHERE es_valido
GROUP BY tipo_taxi
ORDER BY tipo_taxi;