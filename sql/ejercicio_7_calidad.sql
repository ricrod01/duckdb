SELECT
    tipo_taxi,
    count(*) AS registros_totales,
    count(*) FILTER (WHERE es_valido) AS registros_validos,
    count(*) FILTER (WHERE NOT es_valido) AS registros_invalidos,

    100.0 * count(*) FILTER (WHERE NOT es_valido)
        / count(*) AS porcentaje_invalido

FROM viajes_analiticos
GROUP BY tipo_taxi
ORDER BY tipo_taxi;