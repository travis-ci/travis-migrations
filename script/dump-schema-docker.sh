#!/bin/bash

set -e

docker kill postgres-travis-migrations || true
docker rm postgres-travis-migrations || true
docker run --name postgres-travis-migrations -d -p 5433:5432 postgres:9.6

sleep 5

export DATABASE_URL=postgres://postgres@127.0.0.1:5433/postgres

bundle exec rake db:migrate
bundle exec rake db:structure:dump

docker kill postgres-travis-migrations
docker rm postgres-travis-migrations
