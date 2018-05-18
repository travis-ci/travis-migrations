#!/bin/bash

set -e

docker kill travis-migrations || true
docker rm travis-migrations || true
docker run --name travis-migrations -v `pwd`:/travis-migrations -d -p 5433:5432 travis-migrations:0.1

sleep 5

docker exec -it travis-migrations psql -U postgres -c "CREATE ROLE root WITH CREATEDB CREATEROLE LOGIN SUPERUSER"
docker exec -it travis-migrations bundle install --path ./vendor
docker exec -it travis-migrations bundle exec rake db:create
docker exec -it travis-migrations bundle exec rake db:migrate db:structure:dump

docker kill travis-migrations
docker rm travis-migrations
