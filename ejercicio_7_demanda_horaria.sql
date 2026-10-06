SELECT
    dia_semana,
    hora,
    count(*) AS viajes
FROM viajes_analiticos
WHERE es_valido
GROUP BY dia_semana, hora
ORDER BY dia_semana, hora;