-- Evolucion de la mezcla de pagos por anio y tipo de taxi.
SELECT
    anio AS data_year,
    tipo_taxi AS taxi_type,
    forma_pago,
    count(*) AS viajes,
    round(100.0 * count(*) / sum(count(*)) OVER (PARTITION BY anio, tipo_taxi), 2)
        AS porcentaje
FROM viajes_analiticos
WHERE es_valido AND anio IN (2024, 2025, 2026)
GROUP BY anio, tipo_taxi, forma_pago
ORDER BY anio, tipo_taxi, viajes DESC;
