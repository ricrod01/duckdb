SELECT
    pickup_location_id,
    tipo_taxi,
    count(*) AS viajes
FROM viajes_analiticos
WHERE es_valido
  AND pickup_location_id IS NOT NULL
GROUP BY pickup_location_id, tipo_taxi
ORDER BY viajes DESC
LIMIT 15;