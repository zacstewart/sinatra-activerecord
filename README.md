# Sinatra ActiveRecord Extension

## About

Extends [Sinatra](http://www.sinatrarb.com/) with extension methods and Rake
tasks for dealing with an SQL database using the [ActiveRecord ORM](http://api.rubyonrails.org/).

## Instructions

First, put the gem into your `Gemfile` (or install it manually):

```ruby
gem 'sinatra-activerecord'
```

Also put one of the database adapters into your `Gemfile` (or install
them manually):

- `sqlite3` (SQLite)
- `mysql` (MySQL)
- `pg` (PostgreSQL)

Then require the rake tasks and your app in your `Rakefile`:

```ruby
require 'sinatra/activerecord/rake'
require './app'
```

In the terminal, test that it works:

```
$ rake -T
rake db:create_migration  # create an ActiveRecord migration in ./db/migrate
rake db:migrate           # migrate your database
```

Now you can create a migration:

```
$ rake db:create_migration NAME=create_users
```

This will create a migration file in the `./db/migrate` folder, ready for editing.

```ruby
class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :name
    end
  end

  def down
    drop_table :users
  end
end
```

After you've written the migration, migrate the database:

```
$ rake db:migrate
```

You can then also write the model:

```ruby
class User < ActiveRecord::Base
  validates_presence_of :name
end
```

You can put the models anywhere. It's probably best to put them in an
external file, and require them in your `app.rb` aftewards. Usually
models in Sinatra aren't that complex, so you can put them all in one
file, for example `./db/models.rb`.

Now just establish the database connection in your `app.rb`
(let's assume you chose the `sqlite3` adapter), and
require the models if necessary:

```ruby
# app.rb
require 'sinatra'
require 'sinatra/activerecord'

require './db/models'

set :database, 'sqlite://foo.db'
```

Now everything just works:

```ruby
get '/users' do
  @users = User.all
  erb :index
end

get '/users/:id' do
  @user = User.find(params[:id])
  erb :show
end
```

A nice thing is that the `ActiveRecord::Base` class is available to
you through the `database` variable. This means that you can write something
like this:

```ruby
if database.table_exists?('users')
  # Do stuff
else
  raise "The table 'users' doesn't exist."
end
```

## History

This gem was made in 2009 by Blake Mizerany, one of the authors of Sinatra.

## License

[MIT](https://github.com/janko-m/sinatra-activerecord/blob/master/LICENSE)
