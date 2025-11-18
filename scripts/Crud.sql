INSERT INTO municipality (insee_code, municipality_name, postal_code, municipality_certification)
VALUES ('75002', 'Paris 2e', '75002', 1)
ON CONFLICT (insee_code) DO NOTHING;

INSERT INTO road (fantoir_id, road_name, afnor_name, insee_code, road_name_source)
VALUES ('FANTOIR002', 'Boulevard des Italiens', 'BD DES ITALIENS', '75002', 'Source Import')
ON CONFLICT (fantoir_id) DO NOTHING;

INSERT INTO address (
    id, 
    road_id, 
    fantoir_id, 
    number, 
    delivery_label, 
    postal_code, 
    insee_code
)
VALUES (
    'ADDR002',
    (SELECT road_id FROM road WHERE fantoir_id = 'FANTOIR002'),
    'FANTOIR002',
    25,
    '25 Boulevard des Italiens',
    '75002',
    '75002'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO address_position (address_id, lat, lon)
VALUES ('ADDR002', 48.8700, 2.3350);

SELECT 
    a.id,
    a.number,
    a.delivery_label,
    r.road_name,
    m.municipality_name,
    ap.lat,
    ap.lon
FROM address a
JOIN road r ON a.road_id = r.road_id
JOIN municipality m ON a.insee_code = m.insee_code
LEFT JOIN address_position ap ON a.id = ap.address_id
WHERE a.id = 'ADDR002';
--UPDATE
UPDATE municipality 
SET municipality_name = 'Paris 1er Arrondissement'
WHERE insee_code = '75001';

UPDATE address 
SET delivery_label = '10 bis Rue de la Paix',
    rep = 'bis'
WHERE id = 'ADDR001';
--DELETE
DELETE FROM address_position 
WHERE lat IS NULL AND lon IS NULL;

DELETE FROM address_position 
WHERE address_id IN (
    SELECT id FROM address WHERE number IS NULL OR number = 0
);

DELETE FROM cadastral_plot 
WHERE address_id IN (
    SELECT id FROM address WHERE number IS NULL OR number = 0
);

DELETE FROM address 
WHERE number IS NULL OR number = 0;

SELECT * FROM address WHERE id = '07002_k2eyy8_00177';
SELECT * FROM address_position WHERE address_id = '07002_k2eyy8_00177';
SELECT * FROM cadastral_plot WHERE address_id = '07002_k2eyy8_00177';

DELETE FROM address_position 
WHERE address_id = '07002_k2eyy8_00177';

DELETE FROM cadastral_plot 
WHERE address_id = '07002_k2eyy8_00177';

DELETE FROM address 
WHERE id = '07002_k2eyy8_00177';

SELECT id FROM address 
WHERE delivery_label = '10 bis Rue de la Paix'
  AND rep = 'bis';
