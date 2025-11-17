-- ============================================================================
-- Script de nettoyage des colonnes vides (toutes valeurs NULL)
-- ============================================================================

-- ============================================================================
-- PARTIE 1 : DÉTECTION DES COLONNES VIDES
-- ============================================================================

DO $$
DECLARE
  tbl_schema text := 'public';   -- changer si besoin
  tbl_name   text := 'road';  -- remplacer par ta table
  col record;
  cnt bigint;
BEGIN
  FOR col IN
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = tbl_schema
      AND table_name = tbl_name
      AND column_name NOT IN ('id')
    EXECUTE format('SELECT COUNT(*) FROM %I.%I WHERE %I IS NOT NULL', tbl_schema, tbl_name, col.column_name)
    INTO cnt;
    IF cnt = 0 THEN
      RAISE NOTICE 'Colonne vide détectée : %.% (toutes valeurs NULL)', tbl_schema || '.' || tbl_name, col.column_name;
    END IF;
  END LOOP;
END $$;

-- ============================================================================
-- PARTIE 2 : SUPPRESSION AUTOMATIQUE DES COLONNES VIDES
-- ============================================================================
DO $$
DECLARE
  tbl_schema text := 'public';   -- changer si besoin
  tbl_name   text := 'road';  -- remplacer par ta table
  col record;
  cnt bigint;
BEGIN
  FOR col IN
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = tbl_schema
      AND table_name = tbl_name
      AND column_name NOT IN ('id') 
  LOOP
    EXECUTE format('SELECT COUNT(*) FROM %I.%I WHERE %I IS NOT NULL', tbl_schema, tbl_name, col.column_name)
    INTO cnt;
    IF cnt = 0 THEN
      RAISE NOTICE 'Suppression colonne vide : %I.%I -> %I', tbl_schema, tbl_name, col.column_name;
      EXECUTE format('ALTER TABLE %I.%I DROP COLUMN %I CASCADE', tbl_schema, tbl_name, col.column_name);
    END IF;
  END LOOP;
END $$;

-- ============================================================================
-- PARTIE 3 : SUPPRESSION MANUELLE DE COLONNES SPÉCIFIQUES
-- ============================================================================

ALTER TABLE address
DROP COLUMN lat;

