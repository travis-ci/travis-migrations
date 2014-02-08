travis-migrations
=================

Skeleton app to allow migrations to be run for our infrastructures.

Installing
----------

    git clone https://github.com/travis-ci/travis-migrations.git


Updating migrations
-------------------

This pull in the latest migrations from [travis-core](https://github.com/travis-ci/travis-core).

    bundle update --source travis-core
    git add Gemfile.lock && git commit -m "Update travis-core"


Deploy latest migrations
------------------------

Replace `<app>` with the name of the app that contains the database you want to run migrations on.

    git push git@heroku.com:<app>.git
    heroku run bundle exec rake db:migrate --app <app>