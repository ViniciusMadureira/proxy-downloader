CREATE TABLE IF NOT EXISTS country(
  id INT NOT NULL, 
  name VARCHAR(30) NOT NULL, 
  CONSTRAINT pk_country_id PRIMARY KEY(id), 
  CONSTRAINT un_country_name UNIQUE(name)
);
CREATE TABLE IF NOT EXISTS owner(
  id INT NOT NULL, 
  name VARCHAR(80) NOT NULL, 
  CONSTRAINT pk_owner_id PRIMARY KEY(id), 
  CONSTRAINT un_owner_name UNIQUE(name)
);
CREATE TABLE IF NOT EXISTS type(
  id INT NOT NULL, 
  name VARCHAR(20) NOT NULL, 
  CONSTRAINT pk_type_id PRIMARY KEY(id), 
  CONSTRAINT un_type_name UNIQUE(name)
);
CREATE TABLE IF NOT EXISTS port(
  id INT NOT NULL, 
  number INT NOT NULL, 
  CONSTRAINT pk_port_id PRIMARY KEY(id), 
  CONSTRAINT un_port_number UNIQUE(number)
);
CREATE TABLE IF NOT EXISTS proxy(
  id INT NOT NULL, 
  ip VARCHAR(15) NOT NULL, 
  last_update datetime NOT NULL, 
  id_port INT NOT NULL, 
  id_type INT NOT NULL, 
  id_country INT, 
  id_owner INT, 
  CONSTRAINT fk_proxy_id_port_port_id FOREIGN KEY(id_port) REFERENCES port(id), 
  CONSTRAINT fk_proxy_id_type_type_id FOREIGN KEY(id_type) REFERENCES type(id), 
  CONSTRAINT fk_proxy_id_country_country_id FOREIGN KEY(id_country) REFERENCES country(id), 
  CONSTRAINT fk_proxy_id_owner_owner_id FOREIGN KEY(id_owner) REFERENCES owner(id), 
  CONSTRAINT un_proxy_ip_id_port UNIQUE(ip, id_port)
);
