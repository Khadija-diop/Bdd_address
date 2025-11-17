-- ============================================================================
-- Script d'analyse et de requêtes sur les adresses
-- ============================================================================

-- ============================================================================
-- PARTIE 1 : RECHERCHE D'ADRESSES PAR COMMUNE
-- ============================================================================
-- Cette requête récupère toutes les adresses de la commune "Villeneuve-de-Berg"
-- avec leurs détails complets (numéro, voie, code postal, etc.)

-- Colonnes retournées :
--   - a.id : Identifiant unique de l'adresse
--   - a.number : Numéro dans la voie
--   - a.rep : Complément d'adresse (bis, ter, etc.)
--   - r.road_name : Nom de la voie
--   - m.municipality_name : Nom de la commune
--   - a.postal_code : Code postal
-- Jointures :
--   - address → road : via road_id (chaque adresse appartient à une voie)
--   - address → municipality : via insee_code (chaque adresse est dans une commune)
-- ============================================================================
SELECT 
  a.id,                    
  a.number,              
  a.rep,                   
  r.road_name,            
  m.municipality_name,    
  a.postal_code           
FROM address a
JOIN road r ON a.road_id = r.road_id              
JOIN municipality m ON a.insee_code = m.insee_code 
WHERE m.municipality_name = 'Villeneuve-de-Berg'  
ORDER BY r.road_name, a.number;                   
-- ============================================================================
-- PARTIE 2 : MODIFICATION DU TYPE DE COLONNE
-- ============================================================================
ALTER TABLE cadastral_plot
ALTER COLUMN plot_code TYPE VARCHAR(255);

