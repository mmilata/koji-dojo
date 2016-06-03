#!/bin/bash

docker run -d --name=koji-db -e POSTGRES_DB='koji' -e POSTGRES_USER='koji' -e POSTGRES_PASSWORD='mypassword' postgres:9.4

docker run -ti --rm --name=koji-hub -v /opt/koji:/opt/koji -v /opt/koji-clients:/opt/koji-clients --link koji-db:koji-db vrutkovs/koji-dojo-hub

docker stop koji-db && docker rm koji-db
