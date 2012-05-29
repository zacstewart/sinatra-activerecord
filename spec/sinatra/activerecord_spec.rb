require 'spec_helper'

describe "the sinatra extension" do
  before(:each) do
    @app = Class.new(MockSinatraApp)
    ActiveRecord::Base.remove_connection
  end

  let(:test_database_url) { "sqlite:///foo.db" }

  it "exposes the database object" do
    @app.set :database, test_database_url
    @app.should respond_to(:database)
  end

  it "establishes the database connection when set" do
    @app.set :database, test_database_url
    @app.database.should respond_to(:table_exists?)
  end

  it "creates the database file" do
    @app.set :database, test_database_url
    @app.database.connection
    File.exists?('foo.db').should be_true

    FileUtils.rm 'foo.db'
  end

  it "can have the SQLite database in a folder" do
    FileUtils.mkdir "db"
    @app.set :database, "sqlite:///db/foo.db"
    @app.database.connection
    File.exists?('db/foo.db').should be_true

    FileUtils.rm_rf 'db'
  end

  it "establishes the connection if DATABASE_URL is set" do
    ENV['DATABASE_URL'] = test_database_url
    app = Class.new(Sinatra::Base) do
      register Sinatra::ActiveRecordExtension
    end
    expect { ActiveRecord::Base.connection }.to_not raise_error(ActiveRecord::ConnectionNotEstablished)

    ENV.delete('DATABASE_URL')
    FileUtils.rm 'foo.db'
  end

  it "doesn't establish the connection if DATABASE_URL isn't set" do
    app = Class.new(MockSinatraApp)
    expect { ActiveRecord::Base.connection }.to raise_error(ActiveRecord::ConnectionNotEstablished)
  end

  it "raises an ActiveRecord error if database and DATABASE_URL aren't set" do
    expect { @app.database }.to raise_error(ActiveRecord::AdapterNotSpecified)
  end
end
