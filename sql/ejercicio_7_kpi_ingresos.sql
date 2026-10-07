SELECT round(coalesce(sum(total_amount), 0), 2) AS ingresos
FROM viajes_analiticos WHERE es_valido;
