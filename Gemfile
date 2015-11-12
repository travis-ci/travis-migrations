source 'https://rubygems.org'

ruby '2.1.2' if ENV.key?('DYNO')

gem 'travis-core',     github: 'travis-ci/travis-core',                   branch: ENV.fetch('TRAVIS_CORE_BRANCH', 'master')
gem 'travis-support',  github: 'travis-ci/travis-support',                branch: ENV.fetch('TRAVIS_SUPPORT_BRANCH', 'master')
gem 'travis-sidekiqs', github: 'travis-ci/travis-sidekiqs', require: nil, branch: ENV.fetch('TRAVIS_SIDEKIQS_BRANCH', 'master')

gem 'newrelic_rpm', '~> 3.4.2' # required by travis-core, apparently

gem 'rails',                '~> 3.2.12'
gem 'rake'

gem 'rails_12factor'

# db
gem 'pg',                   '~> 0.13.2'
gem 'micro_migrations'
