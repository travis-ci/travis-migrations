FROM ruby:2.5.3

LABEL maintainer Travis CI GmbH <support+travis-migrations-docker-images@travis-ci.com>

RUN apt update && \
    apt install -qq -y --no-install-recommends libgnutls30 && \
    apt-key adv --fetch-keys 'https://www.postgresql.org/media/keys/ACCC4CF8.asc' && \
    echo "deb http://apt.postgresql.org/pub/repos/apt stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt update && \
    apt install -qq -y --no-install-recommends --fix-missing \
                libpq-dev postgresql-client-9.6 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /travis-migrations

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . ./

CMD /bin/bash
