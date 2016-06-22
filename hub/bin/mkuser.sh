#!/bin/bash

set -x

psql="psql --host=koji-db --username=koji koji"

IP=$(find-ip.py || "koji-hub.local")

user=$1
kind=$2
client=/opt/koji-clients/${user}

if [ "x$user" == "x" ]; then
	echo "Usage: $0 <username> [admin|user]"
fi

echo "INSERT INTO users (name, status, usertype) VALUES ('${user}', 0, 0);" | $psql

if [ "x$kind" == "xadmin" ]; then
	uid=$(echo "select id from users where name = '${user}'" | $psql | tail -3 | head -1)
	echo "Assigning admin privileges to: ${user} with uid: ${uid}"
	echo "INSERT INTO user_perms (user_id, perm_id, creator_id) VALUES (${uid}, 1, ${uid});" | $psql
fi

make_certs.sh $user

cat <<EOF > $client/config
[koji]
server = https://${IP}/kojihub
authtype = ssl
cert = ${client}/client.crt
ca = ${client}/clientca.crt
serverca = ${client}/serverca.crt
EOF

cat <<EOF > $client/config.json
{
	"url": "https://${IP}/kojihub",
	"crt-url": "https://${IP}/koji-clients/${user}/client.crt",
	"pem-url": "https://${IP}/koji-clients/${user}/client.pem",
	"ca-url": "https://${IP}/koji-clients/${user}/clientca.crt",
	"serverca-url": "https://${IP}/koji-clients/${user}/serverca.crt",
	"crt": "${client}/client.crt",
	"pem": "${client}/client.pem",
	"ca": "${client}/clientca.crt",
	"serverca": "${client}/serverca.crt"
}
EOF

chown -R nobody:nobody ${client}
