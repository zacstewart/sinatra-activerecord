require 'spec_helper'

describe "the sinatra extension" do
  before(:each) do
    File.unlink 'test.db' rescue nil
    ENV.delete('DATABASE_URL')
    @app = Class.new(MockSinatraApp)
  end

  let(:test_database_url) { "sqlite://test.db" }

  it "exposes the database object" do
    @app.should respond_to(:database)
  end

  it "uses the DATABASE_URL environment variable if set" do
    ENV['DATABASE_URL'] = test_database_url
    @app.database_url.should == test_database_url
  end

  it "uses the SQLite url with environment if no DATABASE_URL is defined" do
    @app.environment = :test
    @app.database_url.should == test_database_url
  end

  it "establishes the database connection when set" do
    @app.set :database, test_database_url
    @app.database.should respond_to(:table_exists?)
  end

  it "can have the SQLite database in a folder" do
    FileUtils.mkdir "db"
    @app.set :database, "sqlite:///db/test.db"
    @app.database.connection
    File.exists?('db/test.db').should be_true

    FileUtils.rm_rf 'db'
  end
end
