SELECT
    count(*) AS viajes,
    sum(total_amount) AS ingresos,
    avg(total_amount) AS ticket_medio,
    median(total_amount) AS ticket_mediano,
    median(trip_distance) AS distancia_mediana,
    avg(duracion_minutos) AS duracion_media
FROM viajes_analiticos
WHERE es_valido;

