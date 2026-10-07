-- Compara cada anio hasta el ultimo mes disponible en TODOS los conjuntos.
WITH cobertura AS (
    SELECT data_year, taxi_type, max(month(pep_pickup_datetime)) AS ultimo_mes
    FROM trips
    WHERE data_year IN (2024, 2025, 2026)
    GROUP BY data_year, taxi_type
), limite AS (
    SELECT min(ultimo_mes)::INTEGER AS ultimo_mes_comparable FROM cobertura
)
SELECT
    v.anio AS data_year,
    v.tipo_taxi AS taxi_type,
    l.ultimo_mes_comparable,
    count(*) AS viajes,
    round(sum(v.total_amount), 2) AS ingresos,
    round(median(v.total_amount), 2) AS ticket_mediano,
    round(median(v.trip_distance), 2) AS distancia_mediana,
    round(avg(v.duracion_minutos), 2) AS duracion_media
FROM viajes_analiticos AS v
CROSS JOIN limite AS l
WHERE v.es_valido
  AND v.anio IN (2024, 2025, 2026)
  AND v.mes <= l.ultimo_mes_comparable
GROUP BY v.anio, v.tipo_taxi, l.ultimo_mes_comparable
ORDER BY v.anio, v.tipo_taxi;
