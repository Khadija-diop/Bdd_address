-- ============================================================================
-- Script d'opérations CRUD (Create, Read, Update, Delete)
-- ============================================================================

-- ============================================================================
-- PARTIE 1 : INSERTION (CREATE)
-- ============================================================================

-- Insertion dans municipality
INSERT INTO municipality (insee_code, municipality_name, postal_code, municipality_certification)
VALUES ('67890', 'Nanterre', '75001', 1)
ON CONFLICT (insee_code) DO NOTHING;

-- Insertion dans road
INSERT INTO road (fantoir_id, road_name, afnor_name, insee_code, road_name_source)
VALUES ('FANTOIR00', 'Rue Disney', 'RUE DISNEY', '67890', 'Source Import')
ON CONFLICT (fantoir_id) DO UPDATE
SET road_name = EXCLUDED.road_name,
    afnor_name = EXCLUDED.afnor_name,
    road_name_source = EXCLUDED.road_name_source,
    insee_code = EXCLUDED.insee_code;

-- Insertion dans address avec récupération du road_id
WITH r AS (
    SELECT road_id FROM road WHERE fantoir_id = 'FANTOIR00'
)
INSERT INTO address (
    id, road_id, fantoir_id, number, rep, delivery_label, cadastral_plots, postal_code, insee_code
)
SELECT
    'ADDR025',
    r.road_id,
    'FANTOIR00',
    22,
    'B',
    '16B Rue Disney',
    '127A',
    '75001',
    '67890'
FROM r
ON CONFLICT (id) DO NOTHING; 

-- Insertion de la position de l'adresse
INSERT INTO address_position (address_id, lat, lon)
VALUES ('ADDR025', 48.8566, 2.3522);


-- ============================================================================
-- PARTIE 2 : MISE À JOUR (UPDATE)
-- ============================================================================
-- Mise à jour du nom de la route via l'adresse
UPDATE road r
SET road_name = 'Land Paris'
FROM address a
WHERE a.road_id = r.road_id
  AND a.id = 'ADDR025';


-- ============================================================================
-- PARTIE 3 : SUPPRESSION (DELETE)
-- ============================================================================
-- Suppression des adresses et données liées si number invalide
DELETE FROM address_position
WHERE address_id IN (
    SELECT id FROM address
    WHERE number IS NULL OR number = 0
);

DELETE FROM cadastral_plot
WHERE address_id IN (
    SELECT id FROM address
    WHERE number IS NULL OR number = 0
);

DELETE FROM address
WHERE number IS NULL OR number = 0;

-- ============================================================================
-- PARTIE 4 : LECTURE (READ) - VÉRIFICATION FINALE
-- ============================================================================
SELECT * FROM municipality WHERE insee_code = '67890';
SELECT * FROM road WHERE fantoir_id = 'FANTOIR00';
SELECT * FROM address WHERE fantoir_id = 'FANTOIR00';
SELECT * FROM address_position WHERE address_id = 'ADDR025';
SELECT * FROM road WHERE road_name = 'Land Paris';
