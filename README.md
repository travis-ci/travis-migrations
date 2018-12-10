travis-migrations
=================

This is the central repository for storing migrations, and executing them against production and development databases on both .org and .com.

Any changes to this document should also be reflected in the [Travis Builders Manual](https://builders.travis-ci.com/engineering/database/migration-processes)

In short, migrations should be run locally while standing in this repository during development. For tests (e.g. via `.travis.yml`) applications should contain their own tooling that loads the schema (e.g. see [travis-hub](https://github.com/travis-ci/travis-hub/blob/master/Rakefile#L12)).

Please use Postgresql 9.6.8 for local development and testing, but note that production and enterprise environments require compatibility with both 9.3 and 9.6.

Installing
----------

``` bash
git clone https://github.com/travis-ci/travis-migrations.git
```

Adding migrations
-------------------

To add a migration, create a file and add it to the `db/main/migrate` folder, making sure the filename contains a timestamp later than the one used in the most recent migration file. See [this guide](http://edgeguides.rubyonrails.org/active_record_migrations.html#creating-a-standalone-migration) for creating standalone migrations.

Please make sure your migrations are production safe as per this guide: [Safe Operations For High Volume PostgreSQL](https://www.braintreepayments.com/blog/safe-operations-for-high-volume-postgresql/).

You can run `script/dump-schema-docker.sh` to generate the schema file
using a consistent version of postgres (running in a docker container).

Using Docker to run on PostgreSQL 9.6
-------------------------------------

We use PostgreSQL 9.6 on production, which is often different than the database
installed on many operating systems by default. In order to make it easier to
run against 9.6 you can use Docker with a supplied docker-compose.yml file.

Run `docker-compose up` to start the container. Then you can either change
settings in `config/database.yml` to use `postgres` as a user and `5431` as a
port, or run with `DATABASE_URL` specified explicitly, for example:

```bash
DATABASE_URL=postgres://postgres@localhost:5431/travis_test bundle exec rake db:migrate
```

Running migrations locally
--------------------------

<em>PLEASE NOTE: the `DATABASE_URL` is the url of the local database that will be created or have migrations run on it. This is configured in the `config/database.yml`. To specify an environment append `RAILS_ENV=` to each bash command, eg to create the test database use:</em>

```bash
RAILS_ENV=test bundle exec rake db:create
```

To setup the database from scratch:

``` bash
bundle exec rake db:create
```

To run migrations after the database has been set up:

``` bash
bundle exec rake db:migrate
```

When getting ActiveRecord::NoEnvironmentInSchemaError error
-----------------------------------------------------------

Since version 5.0 ActiveRecord will complain if the env info is not saved in the
database with an error:

```
ActiveRecord::NoEnvironmentInSchemaError:

Environment data not found in the schema. To resolve this issue, run:

        bin/rails db:environment:set RAILS_ENV=test
```

The command that it outputs will not work, because we don't install rails
scripts. You can run this instead:

```bash
bundle exec rake db:environment:set RAILS_ENV=test
```

You may need to change `RAILS_ENV=test` to whatever environment you're trying to
migrate.

Deploy latest migrations
------------------------

`travis-migrations` is deployed to our database apps, and migrations are run from these apps.

Deployments are done using Slack.
Replace `<env>` with the environment of database you want to run migrations on (e.g. org-staging, com-production).

```
.deploy migrations to <env>
```

To run migrations, from your terminal use `heroku run`.
Replace <app> with the name of the migrations app for the database you want to run migrations on (e.g. `travis-migrations-staging`):

``` bash
heroku run bundle exec rake db:migrate -a <app>
```

To run a single migration, replace <timestamp> with the timestamp of the migration you want to run if required:

**PLEASE NOTE: running this command without `:up` included will result in migrations after the timestamp being reverted**

``` bash
heroku run bundle exec rake db:migrate:up VERSION=<timestamp> -a <app>
```

If you are on a branch and want to push that to staging, ensure the branch has been pushed to GitHub then:
```
.deploy migrations/<branch-name> to <env>
```

If your push is rejected because the tip of your branch is behind the remote counterpart, append `!`

```
.deploy! migrations/<branch-name> to <env>
```
