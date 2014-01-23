travis-migrations
=================

Skeleton app to allow migrations to be run for our infrastructures

Use
=================
```
git clone git@github.com:travis-ci/travis-migrations.git
```

Running migrations
==================
```
cd travis-migrations
heroku run rake db:migrate --app <APP>
```
