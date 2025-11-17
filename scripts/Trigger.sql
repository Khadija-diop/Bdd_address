-- ============================================================================
-- Script de création de triggers et fonctions de validation
-- ============================================================================

-- ============================================================================
-- PARTIE 1 : AJOUT DES COLONNES TIMESTAMP
-- ============================================================================
ALTER TABLE address
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT NOW();


-- ============================================================================
-- PARTIE 2 : FONCTION DE VALIDATION POUR ADDRESS
-- ============================================================================
CREATE OR REPLACE FUNCTION address_upsert_validate()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérification code postal / commune
    IF NOT EXISTS (
        SELECT 1 FROM municipality
        WHERE insee_code = NEW.insee_code
          AND postal_code = NEW.postal_code
    ) THEN
        RAISE EXCEPTION 'Code postal ne correspond pas à la commune';
    END IF;

    -- Timestamps
    IF TG_OP = 'INSERT' THEN
        NEW.created_at := NOW();
        NEW.updated_at := NOW();
    ELSE
        NEW.updated_at := NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_address_upsert ON address;

CREATE TRIGGER trigger_address_upsert
BEFORE INSERT OR UPDATE ON address
FOR EACH ROW EXECUTE FUNCTION address_upsert_validate();


-- ============================================================================
-- PARTIE 3 : FONCTION DE VALIDATION POUR ADDRESS_POSITION
-- ============================================================================
CREATE OR REPLACE FUNCTION address_position_validate()
RETURNS TRIGGER AS $$
DECLARE
    dep_min_lat NUMERIC := 48.8156;
    dep_max_lat NUMERIC := 48.9022;
    dep_min_lon NUMERIC := 2.2241;
    dep_max_lon NUMERIC := 2.4699;
BEGIN
    IF NEW.lat IS NULL OR NEW.lon IS NULL THEN
        RAISE EXCEPTION 'Latitude et longitude doivent être renseignées';
    END IF;

    IF NEW.lat < dep_min_lat OR NEW.lat > dep_max_lat
       OR NEW.lon < dep_min_lon OR NEW.lon > dep_max_lon THEN
        RAISE EXCEPTION 'Coordonnées GPS hors limites du département';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_address_position_validate
BEFORE INSERT OR UPDATE ON address_position
FOR EACH ROW EXECUTE FUNCTION address_position_validate();

-- ============================================================================
-- PARTIE 4 : PRÉPARATION DES DONNÉES DE TEST
-- ============================================================================
SELECT * FROM road WHERE road_id = 1;

INSERT INTO road(road_id, road_name, afnor_name, insee_code)
VALUES (1, 'Rue des Fleurs', 'RUE DES FLEURS', '12345')
ON CONFLICT (road_id) DO NOTHING;

INSERT INTO address(id, road_id, number, rep, delivery_label, cadastral_plots, postal_code, insee_code, lat, lon)
VALUES ('ADDR001', 1, 12, 'B', '12B Rue des Fleurs', '123A', '75001', '12345', 48.85, 2.35)
ON CONFLICT (id) DO UPDATE
SET road_id = EXCLUDED.road_id,
    number = EXCLUDED.number,
    rep = EXCLUDED.rep,
    delivery_label = EXCLUDED.delivery_label,
    cadastral_plots = EXCLUDED.cadastral_plots,
    postal_code = EXCLUDED.postal_code,
    insee_code = EXCLUDED.insee_code,
    lat = EXCLUDED.lat,
    lon = EXCLUDED.lon;


-- ============================================================================
-- PARTIE 5 : TESTS DE VALIDATION
-- ============================================================================
SELECT * FROM municipality WHERE insee_code = '12345' AND postal_code = '75001';

-- Cas valide : devrait passer
INSERT INTO address(id, road_id, number, rep, delivery_label, cadastral_plots, postal_code, insee_code, lat, lon)
VALUES ('ADDR009', 1, 15, 'A', '15A Rue des Fleurs', '124B', '75001', '12345', 48.85, 2.35);

-- Cas invalide GPS : devrait lever une exception
INSERT INTO address(id, road_id, number, rep, delivery_label, cadastral_plots, postal_code, insee_code, lat, lon)
VALUES ('ADDR003', 1, 20, 'C', '20C Rue des Fleurs', '125C', '75001', '12345', 50.0, 2.0);

SELECT id, created_at, updated_at FROM address ORDER BY created_at DESC;

-- ============================================================================
-- PARTIE 6 : VÉRIFICATION DE L'INTÉGRITÉ RÉFÉRENTIELLE
-- ============================================================================
-- Toutes les adresses ont une voie existante ?
SELECT *
FROM address a
WHERE NOT EXISTS (SELECT 1 FROM road r WHERE r.road_id = a.road_id);

-- Toutes les adresses ont une commune existante ?
SELECT *
FROM address a
WHERE NOT EXISTS (SELECT 1 FROM municipality m WHERE m.insee_code = a.insee_code AND m.postal_code = a.postal_code);
