SELECT
    tipo_taxi,
    count(*) AS viajes_tarjeta,
    avg(tip_amount) AS propina_media,
    median(tip_amount) AS propina_mediana,

    100.0 * sum(tip_amount) /
        nullif(sum(fare_amount), 0) AS tasa_propina_pct

FROM viajes_analiticos
WHERE es_valido
  AND payment_type = 1
  AND fare_amount > 0
  AND tip_amount >= 0
GROUP BY tipo_taxi
ORDER BY tipo_taxi;