DO $$
DECLARE
  tbl_schema text := 'public';
  tbl_name   text := 'road';
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
      RAISE NOTICE 'Colonne vide détectée : %.% (toutes valeurs NULL)', tbl_schema || '.' || tbl_name, col.column_name;
    END IF;
  END LOOP;
END $$;

DO $$
DECLARE
  tbl_schema text := 'public';
  tbl_name   text := 'road';
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

ALTER TABLE address
DROP COLUMN lat;
