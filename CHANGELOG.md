# Changelog

## Version 0.2.1

- The previous version was yanked, because I forgot to add the
  `db:rollback` task (I didn't figure out how to test it yet, otherwise
  I would know it was missing). This version is then actually 0.2.0.

## Version 0.2.0 (yanked)

- Added `db:rollback` rake task.

- If you're using SQLite, you can now specify the path to where
  you want your database file to be (thanks to **@mpalmer** for this). Refer to
  [this wiki](https://github.com/janko-m/sinatra-activerecord/wiki/SQLite).

- Verify connection before requests (a MySQL error which caused the
  app to disconnect from the database after some longer time).

- Clear active connections after each request.

- `activerecord` gem is now a dependency, so you don't have to specify
  it anymore. The required version is >= 3.
