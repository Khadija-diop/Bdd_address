INSERT INTO municipality (insee_code, municipality_name, postal_code, municipality_certification)
SELECT DISTINCT
    code_insee,
    nom_commune,
    code_postal,
    certification_commune
FROM adresses
WHERE code_insee IS NOT NULL
ON CONFLICT (insee_code) DO NOTHING;

SELECT DISTINCT
    id_fantoir,
    nom_voie,
    nom_afnor,
    source_nom_voie,
    alias,
    code_insee
FROM adresses
WHERE nom_voie IS NOT NULL
ON CONFLICT (fantoir_id) DO NOTHING;

INSERT INTO address (id, road_id, fantoir_id, number, rep, delivery_label, postal_code, insee_code)
SELECT
    r.id,
    v.road_id,
    r.id_fantoir,
    r.numero,
    r.rep,
    r.libelle_acheminement,
    r.code_postal,
    r.code_insee
FROM adresses r
LEFT JOIN road v ON v.fantoir_id = r.id_fantoir
WHERE r.id IS NOT null
ON CONFLICT (id) DO NOTHING;


INSERT INTO address_position (address_id, x, y, lat, lon, position_type, position_source)
SELECT
    id,
    x,
    y,
    lat,
    lon,
    type_position,
    source_position
FROM adresses
WHERE id IS NOT null;


INSERT INTO cadastral_plot (address_id, plot_code)
SELECT
    id,
    LEFT(cad_parcelles, 50)
FROM adresses
WHERE cad_parcelles IS NOT NULL AND cad_parcelles <> '';


SELECT COUNT(*) AS nb_communes FROM municipality;
SELECT COUNT(*) AS nb_voies FROM road;
SELECT COUNT(*) AS nb_adresses FROM address;
SELECT COUNT(*) AS nb_positions FROM address_position;
SELECT COUNT(*) AS nb_parcelles FROM cadastral_plot;
