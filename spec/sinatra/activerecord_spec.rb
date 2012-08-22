require 'spec_helper'
require 'sinatra/base'
require 'sinatra/activerecord'

describe "the sinatra extension" do
  let(:database_url) { "sqlite:///foo.db" }

  before(:each) do
    @app = Class.new(Sinatra::Base) { register Sinatra::ActiveRecordExtension }
    ActiveRecord::Base.remove_connection
  end

  after(:each) do
    FileUtils.rm_rf("db")
    FileUtils.rm("foo.db") if File.exists?("foo.db")
  end

  context "DATABASE_URL isn't set" do
    it "exposes the database object" do
      @app.set :database, database_url
      @app.should respond_to(:database)
    end

    it "raises the proper error when trying to establish connection with a nonexisting database" do
      expect { @app.database }.to raise_error(ActiveRecord::AdapterNotSpecified)
    end

    it "establishes the database connection when set" do
      @app.set :database, database_url
      expect { ActiveRecord::Base.connection }.to_not raise_error(ActiveRecord::ConnectionNotEstablished)
      last_use = @app.database.connection.last_use.to_f
      @app.set :database, database_url
      @app.database.connection.last_use.to_f.should > last_use
    end

    it "caches the database variable" do
      @app.set :database, database_url
      last_use = @app.database.connection.last_use.to_f
      @app.database.connection.last_use.to_f.should == last_use
    end

    it "creates the database file" do
      @app.set :database, database_url
      @app.database.connection
      File.should exist('foo.db')
    end

    it "can have the SQLite database in a folder" do
      FileUtils.mkdir("db")
      @app.set :database, "sqlite:///db/foo.db"
      expect { @app.database.connection }.to_not raise_error(SQLite3::CantOpenException)
    end

    it "accepts a hash for the database" do
      expect { @app.set :database, {} }.to raise_error(ActiveRecord::AdapterNotSpecified)
      expect { @app.set :database, {adapter: "sqlite3"} }.to_not raise_error(ActiveRecord::AdapterNotSpecified)
    end
  end

  context "DATABASE_URL is set" do
    before(:all) { ENV["DATABASE_URL"] = database_url }
    after(:all) { ENV.delete("DATABASE_URL") }

    it "establishes the connection upon registering" do
      app = Class.new(Sinatra::Base) { register Sinatra::ActiveRecordExtension }
      expect { ActiveRecord::Base.connection }.to_not raise_error(ActiveRecord::ConnectionNotEstablished)
    end
  end
end
