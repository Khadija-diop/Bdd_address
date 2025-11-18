create table municipality (
  insee_code VARCHAR(10) PRIMARY KEY,
  municipality_name VARCHAR(255) NOT NULL,
  postal_code VARCHAR(10),
  municipality_certification INTEGER
);

create table road (
  road_id SERIAL PRIMARY KEY,
  fantoir_id VARCHAR(50) UNIQUE,
  road_name VARCHAR(255) NOT NULL,
  afnor_name VARCHAR(255),
  road_name_source VARCHAR(100),
  alias TEXT,
  insee_code VARCHAR(10) NOT NULL,
  CONSTRAINT fk_road_municipality
    FOREIGN KEY (insee_code)
    REFERENCES municipality(insee_code)
);

create table address (
  id VARCHAR(100) PRIMARY KEY,
  road_id INTEGER,
  fantoir_id VARCHAR(50),
  number INTEGER NOT NULL,
  rep VARCHAR(10),
  delivery_label VARCHAR(255),
  cadastral_plots TEXT,
  postal_code VARCHAR(10) NOT NULL,
  insee_code VARCHAR(10) NOT NULL,
  CONSTRAINT fk_address_road
    FOREIGN KEY (road_id)
    REFERENCES road(road_id),
  CONSTRAINT fk_address_municipality
    FOREIGN KEY (insee_code)
    REFERENCES municipality(insee_code)
);

create table address_position (
  position_id SERIAL PRIMARY KEY,
  address_id VARCHAR(100) NOT NULL,
  x DOUBLE PRECISION,
  y DOUBLE PRECISION,
  lat DOUBLE PRECISION,
  lon DOUBLE PRECISION,
  position_type VARCHAR(50),
  position_source VARCHAR(100),
  position_date TIMESTAMP,
  CONSTRAINT fk_position_address
    FOREIGN KEY (address_id)
    REFERENCES address(id)
);

create table cadastral_plot (
  plot_id SERIAL PRIMARY KEY,
  address_id VARCHAR(100) NOT NULL,
  plot_code VARCHAR(50) NOT NULL,
  section VARCHAR(10),
  number VARCHAR(10),
  area DECIMAL(10,2),
  CONSTRAINT fk_plot_address
    FOREIGN KEY (address_id)
    REFERENCES address(id)
);
