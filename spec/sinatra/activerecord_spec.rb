require 'spec_helper'
require 'sinatra/base'
require 'sinatra/activerecord'

describe "the sinatra extension" do
  let(:database_url) { "sqlite3:///tmp/foo.sqlite3" }

  before(:each) do
    FileUtils.mkdir_p("tmp")
    FileUtils.rm_rf("tmp/foo.sqlite3")

    ActiveRecord::Base.remove_connection
    @app = Class.new(Sinatra::Base) { register Sinatra::ActiveRecordExtension }
  end

  after(:each) do
    FileUtils.rm_rf("tmp")
  end

  it "exposes the database object" do
    @app.should respond_to(:database)
  end

  it "raises the proper error when trying to establish connection with a nonexisting database" do
    expect { @app.database }.to raise_error(ActiveRecord::AdapterNotSpecified)
  end

  it "establishes the database connection when set" do
    @app.set :database, database_url
    expect { ActiveRecord::Base.connection }.to_not raise_error(ActiveRecord::ConnectionNotEstablished)
    expect {
      @app.set :database, database_url
    }.to change{ActiveRecord::Base.connection.last_use}
  end

  it "can have the SQLite database in a folder" do
    @app.set :database, "sqlite3:///tmp/foo.sqlite3"
    expect { ActiveRecord::Base.connection }.to_not raise_error(SQLite3::CantOpenException)
  end

  it "accepts SQLite database URLs without the '3'" do
    @app.set :database, "sqlite:///tmp/foo.sqlite3"
    expect { ActiveRecord::Base.connection }.to_not raise_error(ActiveRecord::AdapterNotFound)
  end

  it "accepts a hash for the database" do
    expect { @app.set :database, {} }.to raise_error(ActiveRecord::AdapterNotSpecified)
    expect { @app.set :database, {adapter: "sqlite3"} }.to_not raise_error(ActiveRecord::AdapterNotSpecified)
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
