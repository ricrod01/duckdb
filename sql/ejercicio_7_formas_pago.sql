SELECT
    tipo_taxi,
    forma_pago,
    count(*) AS viajes,
    100.0 * count(*) /
        sum(count(*)) OVER (PARTITION BY tipo_taxi) AS porcentaje
FROM viajes_analiticos
WHERE es_valido
GROUP BY tipo_taxi, forma_pago
ORDER BY tipo_taxi, viajes DESC;