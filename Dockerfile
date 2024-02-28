FROM ruby:3.2.2-slim

LABEL maintainer Travis CI GmbH <support+travis-migrations-docker-images@travis-ci.com>

RUN apt update && apt install -y --no-install-recommends postgresql-client git make gcc g++ libcurl4 libpq-dev &&    rm -rf /var/lib/apt/lists/*

WORKDIR /travis-migrations

COPY . ./

RUN bundle install

CMD /bin/bash
