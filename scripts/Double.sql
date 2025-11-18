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

CREATE INDEX IF NOT EXISTS idx_address_duplicates_temp 
ON address(number, road_id, postal_code, insee_code, id);

CREATE TEMP TABLE duplicates_temp AS
SELECT id,
       ROW_NUMBER() OVER (
           PARTITION BY number, road_id, postal_code, insee_code
           ORDER BY id ASC
       ) AS rn
FROM address;

CREATE INDEX idx_duplicates_temp_id ON duplicates_temp(id);
CREATE INDEX idx_duplicates_temp_rn ON duplicates_temp(rn) WHERE rn > 1;

DELETE FROM address_position ap
USING duplicates_temp d
WHERE ap.address_id = d.id
  AND d.rn > 1;

DELETE FROM cadastral_plot cp
USING duplicates_temp d
WHERE cp.address_id = d.id
  AND d.rn > 1;

DELETE FROM address a
USING duplicates_temp d
WHERE a.id = d.id
  AND d.rn > 1;

DROP TABLE IF EXISTS duplicates_temp;
DROP INDEX IF EXISTS idx_address_duplicates_temp;

SELECT postal_code, COUNT(*) AS address_count
FROM address
GROUP BY postal_code
HAVING COUNT(*) > 10000
ORDER BY address_count DESC;

SELECT municipality_name, COUNT(*)
FROM municipality 
GROUP BY municipality_name 
HAVING COUNT(*) > 1;
