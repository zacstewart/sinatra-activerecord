# Changelog

## Version 0.2.0

- Added `db:rollback` rake task.

- If you're using SQLite, you can now specify the path to where
  you want your database file to be. Refer to
  [this wiki](https://github.com/janko-m/sinatra-activerecord/wiki/SQLite).

- Verify connection before requests (a MySQL error which caused the
  app to disconnect from the database after some longer time).

- Clear active connections after each request.

- `activerecord` gem is now a dependency, so you don't have to specify
  it anymore. The required version is >= 3.
