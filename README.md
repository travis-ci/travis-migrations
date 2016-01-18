travis-migrations
=================

App to allow migrations to be run on our infrastructures.

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
(this creates the database, loads the schema, and initializes it with the seed data.)

``` bash
bundle exec rake db:setup
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
Any .com related migrations must be run using `travis-pro-migrations`.
