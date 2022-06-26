/*
while read country; do sqlite3 proxies.db "INSERT INTO country (name) VALUES ('$country')"; done < countries.txt
pragma foreign_keys = on
.headers on
sqlite3 proxies.db ".headers on" "SELECT * FROM country;"
proxies.db ".headers on" "select * from proxy"
sqlite3 proxies.db < tables.sql
rm -rf proxies.db; sqlite3 proxies.db < tables.sql; ./proxy_download.sh
sqlite3 proxies.db ".headers on" "SELECT proxy.ip, port.number FROM proxy INNER JOIN country ON proxy.id_country = country.id INNER JOIN port ON proxy.id_port = port.id WHERE country.name = 'Albania'"
sqlite3 proxies.db ".mode column" ".headers on" "SELECT proxy.ip, port.number FROM proxy INNER JOIN country ON proxy.id_country = country.id INNER JOIN port ON proxy.id_port = port.id WHERE country.name = 'Vietnam'"
*/


/* CREATE TABLES */
sqlite3 proxies.db "CREATE TABLE IF NOT EXISTS country(id INT NOT NULL, name VARCHAR(30) NOT NULL, CONSTRAINT pk_country_id PRIMARY KEY(id), CONSTRAINT un_country_name UNIQUE(name));"
sqlite3 proxies.db "CREATE TABLE IF NOT EXISTS owner(id INT NOT NULL, name VARCHAR(80) NOT NULL,  CONSTRAINT pk_owner_id PRIMARY KEY(id), CONSTRAINT un_owner_name UNIQUE(name));"
sqlite3 proxies.db "CREATE TABLE IF NOT EXISTS type(id INT NOT NULL, name VARCHAR(20) NOT NULL, CONSTRAINT pk_type_id PRIMARY KEY(id), CONSTRAINT un_type_name UNIQUE(name));"
sqlite3 proxies.db "CREATE TABLE IF NOT EXISTS port(id INT NOT NULL, number INT NOT NULL, CONSTRAINT pk_port_id PRIMARY KEY(id), CONSTRAINT un_port_number UNIQUE(number));"
sqlite3 proxies.db "CREATE TABLE IF NOT EXISTS proxy(id INT NOT NULL, ip VARCHAR(15) NOT NULL, last_update datetime NOT NULL, id_port INT NOT NULL, id_type INT NOT NULL, id_country INT, id_owner INT, CONSTRAINT fk_proxy_id_port_port_id FOREIGN KEY(id_port) REFERENCES port(id), CONSTRAINT fk_proxy_id_type_type_id FOREIGN KEY(id_type) REFERENCES type(id), CONSTRAINT fk_proxy_id_country_country_id FOREIGN KEY(id_country) REFERENCES country(id), CONSTRAINT fk_proxy_id_owner_owner_id FOREIGN KEY(id_owner) REFERENCES owner(id), CONSTRAINT un_proxy_ip_id_port UNIQUE(ip, id_port));"


/* SEED TABLES*/

/*
sqlite3 proxies.db "INSERT INTO port(id, number) VALUES (1, 80);"
sqlite3 proxies.db "INSERT INTO port(id, number) VALUES (2, 443);"
sqlite3 proxies.db "INSERT INTO port(id, number) VALUES (3, 3128);"
sqlite3 proxies.db "INSERT INTO port(id, number) VALUES (4, 8080);"
sqlite3 proxies.db "INSERT INTO port(id, number) VALUES (5, 53281);"

sqlite3 proxies.db "INSERT INTO owner(id, name) VALUES (1, 'Ucom LLC');"
sqlite3 proxies.db "INSERT INTO owner(id, name) VALUES (2, 'Hutchison Global Communications');"
sqlite3 proxies.db "INSERT INTO owner(id, name) VALUES (3, 'Mobile TeleSystems JLLC');"
sqlite3 proxies.db "INSERT INTO owner(id, name) VALUES (4, 'True Internet');"
sqlite3 proxies.db "INSERT INTO owner(id, name) VALUES (5, 'China Telecom fujian');"

sqlite3 proxies.db "INSERT INTO type(id, name) VALUES (1, 'transparent ');"
sqlite3 proxies.db "INSERT INTO type(id, name) VALUES (2, 'anonymous');"
sqlite3 proxies.db "INSERT INTO type(id, name) VALUES (3, 'high-anonymous');"

index=1; while read country; do sqlite3 proxies.db "INSERT INTO country (id, name) VALUES ($((index++)), '$country')"; done < countries.txt
*/
