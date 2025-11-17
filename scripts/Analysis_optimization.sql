-- ============================================================================
-- Script d'analyse et d'optimisation des performances
-- ============================================================================
-- ============================================================================
-- PARTIE 1 : ANALYSE DES PERFORMANCES AVANT OPTIMISATION
-- ============================================================================
EXPLAIN ANALYZE
SELECT *
FROM address
WHERE insee_code = '94046';

-- ============================================================================
-- PARTIE 2 : CRÉATION D'INDEX SUR LES CLÉS ÉTRANGÈRES
-- ============================================================================
CREATE INDEX idx_address_insee ON address(insee_code);
CREATE INDEX idx_address_road_id ON address(road_id);
CREATE INDEX idx_road_insee ON road(insee_code);

-- ============================================================================
-- PARTIE 3 : CRÉATION D'INDEX SUR LES RELATIONS ENFANT
-- ============================================================================
CREATE INDEX idx_address_position_address ON address_position(address_id);
CREATE INDEX idx_cadastral_plot_address ON cadastral_plot(address_id);

-- ============================================================================
-- PARTIE 4 : CRÉATION D'INDEX SUR LES COLONNES DE RECHERCHE FRÉQUENTES
-- ============================================================================
CREATE INDEX idx_address_postal_code ON address(postal_code);
CREATE INDEX idx_municipality_name ON municipality(municipality_name);
CREATE INDEX idx_road_name ON road(road_name);
-- Index GIN pour recherche full-text
CREATE INDEX idx_road_name_gin ON road USING gin (to_tsvector('french', road_name));

-- ============================================================================
-- PARTIE 5 : TEST DE RECHERCHE FULL-TEXT
-- ============================================================================
SELECT *
FROM road
WHERE to_tsvector('french', road_name) @@ plainto_tsquery('french', 'clé');

-- ============================================================================
-- PARTIE 6 : ANALYSE DES PERFORMANCES APRÈS OPTIMISATION
-- ============================================================================
EXPLAIN ANALYZE
SELECT *
FROM address
WHERE insee_code = '94046';

-- ============================================================================
-- PARTIE 7 : ANALYSE DE LA TAILLE DES TABLES
-- ============================================================================
SELECT pg_size_pretty(pg_total_relation_size('address'));
SELECT pg_size_pretty(pg_total_relation_size('road'));
SELECT pg_size_pretty(pg_total_relation_size('municipality'));
SELECT pg_size_pretty(pg_total_relation_size('address_position'));
SELECT pg_size_pretty(pg_total_relation_size('cadastral_plot'));
