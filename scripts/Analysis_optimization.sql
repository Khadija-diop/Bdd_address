
EXPLAIN ANALYZE
SELECT *
FROM address
WHERE insee_code = '94046';

CREATE INDEX idx_address_insee ON address(insee_code);
CREATE INDEX idx_address_road_id ON address(road_id);
CREATE INDEX idx_road_insee ON road(insee_code);

CREATE INDEX idx_address_position_address ON address_position(address_id);
CREATE INDEX idx_cadastral_plot_address ON cadastral_plot(address_id);

CREATE INDEX idx_address_postal_code ON address(postal_code);
CREATE INDEX idx_municipality_name ON municipality(municipality_name);
CREATE INDEX idx_road_name ON road(road_name);
CREATE INDEX idx_road_name_gin ON road USING gin (to_tsvector('french', road_name));

CREATE INDEX IF NOT EXISTS idx_address_duplicates 
ON address(number, road_id, postal_code, insee_code, id);

SELECT *
FROM road
WHERE to_tsvector('french', road_name) @@ plainto_tsquery('french', 'clé');

EXPLAIN ANALYZE
SELECT *
FROM address
WHERE insee_code = '94046';

SELECT pg_size_pretty(pg_total_relation_size('address'));
SELECT pg_size_pretty(pg_total_relation_size('road'));
SELECT pg_size_pretty(pg_total_relation_size('municipality'));
SELECT pg_size_pretty(pg_total_relation_size('address_position'));
SELECT pg_size_pretty(pg_total_relation_size('cadastral_plot'));
