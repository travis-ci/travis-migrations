Functions and triggers for populating, aggregating, and keeping repo counts up to date.

* Functions for populating counts from existing records are in `repo_counts_populate.sql`.
* Functions and triggers for keeping counts up to date are in `repo_counts_triggers.sql`.
* Functions for aggregating counts are in `repo_counts_aggregate.sql`.

```
=# \d repo_counts
          Table "public.repo_counts"
    Column     |       Type        | Modifiers
---------------+-------------------+-----------
 repository_id | integer           | not null
 requests      | integer           |
 commits       | integer           |
 branches      | integer           |
 pull_requests | integer           |
 tags          | integer           |
 builds        | integer           |
 stages        | integer           |
 jobs          | integer           |
 range         | character varying |
Indexes:
    "ix_repo_counts_on_repo_and_owner_and_range" UNIQUE, btree (repository_id, owner_id, owner_type, range)
    "index_repo_counts_on_owner_id_and_owner_type" btree (owner_id, owner_type)
    "index_repo_counts_on_repository_id" btree (repository_id)
```

Population and triggers insert records to `repo_counts`. E.g.:

```
 repository_id | requests | ... | range
---------------+----------+-----+------
             1 |        1 |     |
             1 |        1 |     |
             1 |        1 |     |
```

Aggregation compacts these records by `repository_id`. E.g.:

```
 repository_id | requests | ... | range
---------------+----------+-----+------
             1 |        3 |     |
```

There are two functions for aggregating `repo_counts`:

```
agg_all_repo_counts()     # aggregate all records where there is more than 1 record per repo
agg_repo_counts(_repo_id) # aggregate records for the given owner
```

Triggers and population functions depend on a cutoff timestamp (`now() >
'2018-MM-DD HH:MM:SS'`).  This timestamp is interpolated to be `Time.now.utc`
in production when the migration is run. (They are left untouched in test and
development so that the tests are unaffected by this cutoff timestamp, and the
structure.sql is not constantly updated when the migrations are being run
locally.

Population functions can then be run manually after that:

```
select * from count_all_requests(1000);
select * from count_all_commits(1000);
select * from count_all_branches(1000);
select * from count_all_pull_requests(1000);
select * from count_all_tags(1000);
select * from count_all_builds(1000);
select * from count_all_jobs(1000);

select agg_all_repo_counts();
```
