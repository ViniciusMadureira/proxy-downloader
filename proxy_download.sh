#!/bin/bash

function extract() {
for page in {1..14}; do
	page=$(printf "%02d" $page)
	echo -e "\n####################### Page: $page #######################"
	table_rows=$(curl --silent  "http://nntime.com/proxy-list-$page.htm" | grep --null-data --text --only-matching '<tr class=.*\/tr>' | sed -e ':a;N;$!ba;s/\n//g'| tr '\0' '\n')
	table_rows=$(echo -e "$table_rows" | sed 's/<tr /\n<tr /g')
	IFS=$'\n'
	for row in $table_rows; do
		row=$(echo "$row" | sed 's/<td/\n<td/g')
		port_length=$(echo "$row" | sed '3p; d' | grep --perl-regexp --only-match '(\+\w)+' | sed 's/\+//g' | awk '{print length}')	
		port=$(echo "$row" | sed '2p; d'| grep --perl-regexp --only-match '(?<=\")((\d+)+(\.)?)+' | grep --perl-regexp --only-match ".{$port_length}$")
		ip=$(echo "$row" | grep --perl-regex --only-match '(?<=\>)(\d{1,3}(\.)?){4}')	
		type=$(echo "$row" | sed --expression '4p; d;' | sed 's/<\/\?td>//g')	
		updated=$(echo "$row" | sed '5p; d' | grep --perl-regexp --only-match '(\w{3})-(\d{1,2})-(\d{4})')" "$(echo "$row" | sed '5p; d' | grep --perl-regexp --only-match '\d{2}:.*GMT')
		country=$(echo "$row" | sed '6p; d' | sed --expression 's/<\/\?td>//g' --expression 's/ \?(.*)//g')	
		owner=$(echo "$row" | sed '7p; d' | sed --expression 's/<\/\?t\(d\|r\)>//g' --expression 's/.*>//g')
		proxy=(["ip"]=$ip ["port"]=$port ["type"]=$type ["country"]=$country ["owner"]=$owner)
		transform
	done
done
}

function transform() {
	proxy["ip"]=$(echo ${proxy["ip"]} | cut --characters=1-15)
	proxy["port"]=$(echo "${proxy["port"]}" | cut --characters=1-5)
	resultset=$(sqlite3 proxies.db "SELECT ip as proxy_ip, id_port as proxy_port FROM proxy INNER JOIN port ON proxy.id_port = port.id WHERE proxy_ip='$ip' AND proxy_port=$port;")	
	if [[ -z "$resultset" ]]; then
		proxy["type"]=$(echo "${proxy["type"]}" | sed --expression='s/ \|proxy//g' | cut --characters=1-20)
		proxy["last_update"]=$(date --date "${proxy["last_update"]}" "+%Y-%m-%d %H:%M:%S")
		if [[ ${proxy["country"]} =~ ", " ]]; then 
			proxy["country"]=$(echo $country | grep --perl-regexp --only-matching '(?U).*(?=,)' | cut --characters=1-30)
		fi
		proxy["owner"]=$(echo "${proxy["owner"]}" | cut --characters=1-80)
		load
	fi
}

function load() {
	echo -e "\n----------------Trying to insert proxy:----------------\n
IP: ${proxy["ip"]}\nPort: ${proxy["port"]}\nType: ${proxy["type"]}\nCountry: ${proxy["country"]}\nOwner: ${proxy["owner"]}\nLast update: ${proxy["last_update"]}\n
-------------------------------------------------------"
	dataset=(["table"]="proxy")
	proxy["id"]=$(get_next_id "${dataset["table"]}")
	dataset=(["table"]="port" ["column"]="number" ["signal"]="=" ["value"]=${proxy["port"]})
	proxy["port"]=$(get_id)
	dataset=(["table"]="type" ["column"]="name" ["signal"]="=" ["value"]=\'${proxy["type"]}\')
	proxy["type"]=$(get_id)
	dataset=(["table"]="country" ["column"]="name" ["signal"]="LIKE" ["value"]=\'$(echo ${proxy["country"]} | sed --expression='s/^\|$\| /%/g')\')
	proxy["country"]=$(get_id)
	dataset=(["table"]="owner" ["column"]="name" ["signal"]="=" ["value"]=\'$(echo ${proxy["owner"]} | sed --expression="s/'//g")\')
	proxy["owner"]=$(get_id)
	sqlite3 proxies.db "INSERT INTO proxy (id, ip, last_update, id_port, id_type, id_country, id_owner) VALUES (${proxy["id"]}, '${proxy["ip"]}', '${proxy["last_update"]}', ${proxy["port"]}, ${proxy["type"]}, ${proxy["country"]}, ${proxy["owner"]});"
}

function get_id() {
	id=$(sqlite3 proxies.db "SELECT id FROM ${dataset["table"]} WHERE ${dataset["column"]} ${dataset["signal"]} ${dataset["value"]} LIMIT 1;")
	if [[ -z "$id" ]]; then
		id=$(get_next_id "${dataset["table"]}")
		if [[ ${dataset["table"]} == "country" ]]; then
			dataset["value"]=$(echo "${dataset["value"]}" | sed --expression='s/%/ /g' --expression="s/' \| '/'/g")
		fi
		sqlite3 proxies.db "INSERT INTO ${dataset["table"]} VALUES ($id, ${dataset["value"]});"
	fi
	echo "$id"
}

function get_next_id() {
	echo $(($(sqlite3 proxies.db "SELECT MAX(id) FROM ${dataset["table"]};") + 1))
}

export TZ="Etc/GMT"
declare -A proxy dataset
extract
exit 0
