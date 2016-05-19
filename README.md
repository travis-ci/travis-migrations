travis-migrations
=================

<em>PLEASE NOTE: Any .com related migrations must be run using [`travis-pro-migrations`](https://github.com/travis-pro/travis-pro-migrations). Please refer to the README in that repository.</em>
_________________

This is the central repository for storing migrations, and executing them against production and development databases.

In short, migrations should be run locally while standing in this repository during development. For tests (e.g. via `.travis.yml`) applications should contain their own tooling that loads the schema (e.g. see [travis-hub](https://github.com/travis-ci/travis-hub/blob/master/Rakefile#L12)).

Installing
----------

``` bash
git clone https://github.com/travis-ci/travis-migrations.git
```

Use Postgresql

Adding migrations
-------------------

To add a migration, create a file and add it to the `db/migrate` folder, making sure the filename contains a timestamp later than the one used in the most recent migration file. See [this guide](http://edgeguides.rubyonrails.org/active_record_migrations.html#creating-a-standalone-migration) for creating standalone migrations.

Updating migrations
-------------------

It's no longer necessary to pull in migrations from `travis-core`.
Migrations now live in this repo, in the `db/migrate` folder.

Running migrations locally
--------------------------

To setup the database from scratch:
(this creates the database)

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

Replace `<app>` with the name of the app that contains the database you want to run migrations on (e.g. travis-staging).
Replace `<timestamp>` with the timestamp of the migration you want to run.


``` bash
git push git@heroku.com:<app>.git
heroku run bundle exec rake db:migrate VERSION=<timestamp> -a <app>
```
<em>PLEASE NOTE: Any .com related migrations must be run using [`travis-pro-migrations`](https://github.com/travis-pro/travis-pro-migrations). Please refer to the README in that repository.</em>

----
