travis-migrations
=================
_________________

This is the central repository for storing migrations, and executing them against production and development databases on both .org and .com.

Any changes to this document should also be reflected in the [Travis Builders Manual](https://builders.travis-ci.com/engineering/database/migration-processes)

In short, migrations should be run locally while standing in this repository during development. For tests (e.g. via `.travis.yml`) applications should contain their own tooling that loads the schema (e.g. see [travis-hub](https://github.com/travis-ci/travis-hub/blob/master/Rakefile#L12)).

Please use Postgresql 9.4 for local development and testing.

Installing
----------

``` bash
git clone https://github.com/travis-ci/travis-migrations.git
```

Adding migrations
-------------------

To add a migration, create a file and add it to the `db/main/migrate` or `db/logs/migrate` folders, making sure the filename contains a timestamp later than the one used in the most recent migration file. See [this guide](http://edgeguides.rubyonrails.org/active_record_migrations.html#creating-a-standalone-migration) for creating standalone migrations.

Running migrations locally
--------------------------

<em>PLEASE NOTE: the `DATABASE_URL` (or `LOGS_DATABASE_URL` for logs migrations) is the url of the local database that will be created or have migrations run on it. This is configured in the `config/database.yml`. To specify an environment append `RAILS_ENV=` to each bash command, eg to create the test database use:</em>

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

To run a standalone migration:
(replace `<timestamp>`with the timestamp of the migration you want to run.)

``` bash
bundle exec rake db:migrate VERSION=<timestamp>
```

Deploy latest migrations
------------------------

`travis-migrations` is deployed to our database apps, and migrations are run from these apps.

Deployments are done using Slack.
Replace `<env>` with the environment of database you want to run migrations on (e.g. org-staging, com-production).

```
.deploy migrations to <env>
```

To run migrations, from your terminal use `heroku run`.
Replace <app> with the name of the app that contains the database you want to run migrations on (e.g. travis-staging):

``` bash
heroku run bundle exec rake db:migrate -a <app>
```

Replace <timestamp> with the timestamp of the migration you want to run if required:

``` bash
heroku run bundle exec rake db:migrate VERSION=<timestamp> -a <app>
```

If you are on a branch and want to push that to staging, ensure the branch has been pushed to GitHub then:
```
.deploy migrations/<branch-name> to <env>
```

If your push is rejected because the tip of your branch is behind the remote counterpart, append `!`

```
.deploy! migrations/<branch-name> to <env>
```

Logs database
-------------

To run the migration commands for the logs database, set `RAILS_ENV=development_logs` or `RAILS_ENV=test_logs`as an environment variable.

Running locally:

``` bash
RAILS_ENV=development_logs bundle exec rake db:migrate
```

Running remotely:
**PLEASE NOTE: Logs migrations are run from our _main_ databases.** Replace <app> with the name of the _main database_ app that contains the database you want to run migrations on (e.g. travis-staging, travis-pro-staging etc):

``` bash
heroku run RAILS_ENV=production_logs bundle exec rake db:migrate VERSION=<timestamp> -a <app>
```
