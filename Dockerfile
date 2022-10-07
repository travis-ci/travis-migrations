FROM postgres:11

LABEL maintainer Travis CI GmbH <support+travis-migrations-docker-images@travis-ci.com>

RUN mkdir /travis-migrations
WORKDIR /travis-migrations

# ruby deps
RUN ( \
  apt-get update; \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y; \
  apt-get install -y wget build-essential bison zlib1g-dev libyaml-dev libssl1.0-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev openssl curl shared-mime-info; \
  wget -O ruby-install-0.6.1.tar.gz https://github.com/postmodern/ruby-install/archive/v0.6.1.tar.gz; \
  tar -xzvf ruby-install-0.6.1.tar.gz; \
  cd ruby-install-0.6.1/ && make install; \
  cd - && rm -r ruby-install-0.6.1/; \
  rm -f /usr/local/bin/gosu; \
)

# ruby
COPY . .
RUN ( \
  ruby-install --system --no-install-deps ruby `cat .ruby-version`; \
  which ruby; \
  apt-get install -y libpq-dev && rm -rf /var/lib/apt/lists/*; \
  gem install bundler -v 2.3.7; \
  bundle install; \
)

CMD /bin/bash
