travis-migrations
=================

Skeleton app to allow migrations to be run for our infrastructures

Use
=================
```
git clone git@github.com:travis-ci/travis-migrations.git
```

Updating migrations
===================

Whenever new migrations are added to travis-core, you need to update the
travis-core Gem and push this app to Heroku.

```
bundle update --source travis-core
git add Gemfile.lock && git commit
git push git@heroku.com:<APP>.git
```

Running migrations
==================
```
cd travis-migrations
heroku run rake db:migrate --app <APP>
```
