WITH top_zonas AS (
    SELECT pickup_location_id
    FROM viajes_analiticos
    WHERE es_valido AND pickup_location_id IS NOT NULL
    GROUP BY pickup_location_id
    ORDER BY count(*) DESC
    LIMIT 15
)
SELECT
    v.pickup_location_id,
    v.tipo_taxi,
    count(*) AS viajes
FROM viajes_analiticos AS v
JOIN top_zonas AS z USING (pickup_location_id)
WHERE v.es_valido
GROUP BY v.pickup_location_id, v.tipo_taxi
ORDER BY sum(count(*)) OVER (PARTITION BY v.pickup_location_id) DESC,
         v.pickup_location_id, v.tipo_taxi;
