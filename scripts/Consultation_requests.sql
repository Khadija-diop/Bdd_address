SELECT a.id,
       a.number,
       a.rep,
       r.road_name,
       a.delivery_label,
       a.postal_code
FROM address a
JOIN road r ON a.road_id = r.road_id
JOIN municipality m ON a.insee_code = m.insee_code
WHERE m.municipality_name = 'Montpezat-sous-Bauzon'
ORDER BY r.road_name, a.number;

SELECT m.municipality_name,
       r.road_name,
       COUNT(*) AS nombre_adresses
FROM address a
JOIN road r ON a.road_id = r.road_id
JOIN municipality m ON a.insee_code = m.insee_code
GROUP BY m.municipality_name, r.road_name
ORDER BY m.municipality_name, r.road_name;

SELECT DISTINCT m.municipality_name
FROM address a
JOIN municipality m ON a.insee_code = m.insee_code
ORDER BY m.municipality_name;

SELECT a.id,
       a.number,
       a.rep,
       r.road_name,
       a.delivery_label,
       a.postal_code
FROM address a
JOIN road r ON a.road_id = r.road_id
WHERE r.road_name ILIKE '%Boulevard%';

SELECT a.id,
       a.number,
       a.rep,
       r.road_name,
       a.delivery_label,
       a.postal_code AS address_postal_code,
       m.postal_code AS municipality_postal_code,
       m.municipality_name
FROM address a
JOIN municipality m ON a.insee_code = m.insee_code
JOIN road r ON a.road_id = r.road_id
WHERE (a.postal_code IS NULL OR a.postal_code = '')
  AND m.municipality_name IS NOT NULL;
