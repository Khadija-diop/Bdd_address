-- ============================================================================
-- Script de détection et suppression des doublons
-- ============================================================================

-- ============================================================================
-- PARTIE 1 : VÉRIFICATION DES DOUBLONS DANS ADDRESS
-- ============================================================================
SELECT 
    number,
    road_id,
    postal_code,
    insee_code,
    COUNT(*) AS duplicate_count,
    ARRAY_AGG(id) AS address_ids
FROM address
GROUP BY number, road_id, postal_code, insee_code
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ============================================================================
-- PARTIE 2 : SUPPRESSION DES DOUBLONS EN CASCADE
-- ============================================================================
-- Supprimer les address_position liées aux doublons
WITH duplicates AS (
    SELECT id,
           ROW_NUMBER() OVER (
               PARTITION BY number, road_id, postal_code, insee_code
               ORDER BY id ASC
           ) AS rn
    FROM address
)
DELETE FROM address_position ap
USING duplicates d
WHERE ap.address_id = d.id
  AND d.rn > 1;

-- Supprimer les cadastral_plot liées aux doublons
WITH duplicates AS (
    SELECT id,
           ROW_NUMBER() OVER (
               PARTITION BY number, road_id, postal_code, insee_code
               ORDER BY id ASC
           ) AS rn
    FROM address
)
DELETE FROM cadastral_plot cp
USING duplicates d
WHERE cp.address_id = d.id
  AND d.rn > 1;

-- Supprimer les doublons dans address (garder rn = 1)
WITH duplicates AS (
    SELECT id,
           ROW_NUMBER() OVER (
               PARTITION BY number, road_id, postal_code, insee_code
               ORDER BY id ASC
           ) AS rn
    FROM address
)
DELETE FROM address a
USING duplicates d
WHERE a.id = d.id
  AND d.rn > 1;


-- ============================================================================
-- PARTIE 3 : VÉRIFICATION APRÈS SUPPRESSION
-- ============================================================================
-- Vérifier les codes postaux ayant plus de 10 000 adresses
SELECT postal_code, COUNT(*) AS address_count
FROM address
GROUP BY postal_code
HAVING COUNT(*) > 10000
ORDER BY address_count DESC;

-- Vérifier les doublons de noms de communes
SELECT municipality_name, COUNT(*)
FROM municipality 
GROUP BY municipality_name 
HAVING COUNT(*) > 1;
