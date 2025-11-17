-- ============================================================================
-- Script d'analyse et de statistiques sur les adresses
-- ============================================================================

-- ============================================================================
-- PARTIE 1 : STATISTIQUES PAR COMMUNE
-- ============================================================================
-- Nombre total d'adresses par commune avec moyenne d'adresses par voie
SELECT 
    m.municipality_name,
    COUNT(a.id) AS total_addresses,
    ROUND(AVG(COUNT(a.id)) OVER (PARTITION BY m.municipality_name)::numeric, 2) AS avg_addresses_per_road
FROM address a
JOIN road r ON a.road_id = r.road_id
JOIN municipality m ON a.insee_code = m.insee_code
GROUP BY m.municipality_name
ORDER BY m.municipality_name;


-- ============================================================================
-- PARTIE 2 : TOP 10 DES COMMUNES AVEC LE PLUS D'ADRESSES
-- ============================================================================
SELECT 
    m.municipality_name,
    COUNT(a.id) AS total_addresses
FROM address a
JOIN municipality m ON a.insee_code = m.insee_code
GROUP BY m.municipality_name
ORDER BY total_addresses DESC
LIMIT 10;

-- ============================================================================
-- PARTIE 3 : AUDIT DE QUALITÉ DES DONNÉES
-- ============================================================================
-- Vérification du taux de remplissage des colonnes importantes
SELECT
    COUNT(*) AS total_addresses,
    COUNT(*) FILTER (WHERE number IS NOT NULL) AS number_filled,
    COUNT(*) FILTER (WHERE road_id IS NOT NULL) AS road_filled,
    COUNT(*) FILTER (WHERE postal_code IS NOT NULL) AS postal_code_filled,
    COUNT(*) FILTER (WHERE insee_code IS NOT NULL) AS insee_code_filled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE number IS NOT NULL)/COUNT(*), 2) AS pct_number_filled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE road_id IS NOT NULL)/COUNT(*), 2) AS pct_road_filled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE postal_code IS NOT NULL)/COUNT(*), 2) AS pct_postal_code_filled,
    ROUND(100.0 * COUNT(*) FILTER (WHERE insee_code IS NOT NULL)/COUNT(*), 2) AS pct_insee_filled
FROM address;
