travis-migrations
=================
_________________

This is the central repository for storing migrations, and executing them against production and development databases on both .org and .com.

In short, migrations should be run locally while standing in this repository during development. For tests (e.g. via `.travis.yml`) applications should contain their own tooling that loads the schema (e.g. see [travis-hub](https://github.com/travis-ci/travis-hub/blob/master/Rakefile#L12)).

Please use Postgresql 9.4 for local development and testing.

Installing
----------

``` bash
git clone https://github.com/travis-ci/travis-migrations.git
```


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

<em>(PLEASE NOTE: the DATABASE_NAME is the name of the local database you wish to create or run migrations on, either `travis_development`, `travis_pro_development`, `travis_test`, or `travis_pro_test`)</em>

``` bash
DATABASE_NAME=<database_name> bundle exec rake db:create
```

To run migrations after the database has been set up:

``` bash
DATABASE_NAME=<database_name> bundle exec rake db:migrate
```



To run a standalone migration:
(replace `<timestamp>`with the timestamp of the migration you want to run.)

``` bash
DATABASE_NAME=<database_name> bundle exec rake db:migrate VERSION=<timestamp>
```


Deploy latest migrations
------------------------

Replace `<app>` with the name of the app that contains the database you want to run migrations on (e.g. travis-staging).
Replace `<timestamp>` with the timestamp of the migration you want to run.


``` bash
git push git@heroku.com:<app>.git
heroku run bundle exec rake db:migrate VERSION=<timestamp> -a <app>
```

Append `HEAD:master` to the pit push if you are on a branch and want to push that to staging eg:
``` bash
git push git@heroku.com:<app>.git HEAD:master
```



----
