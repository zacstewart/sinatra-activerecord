require 'spec_helper'
require 'sinatra/activerecord/rake'
require 'fileutils'

describe "rake tasks" do
  include Sinatra::ActiveRecordTasks

  def current_version
    ActiveRecord::Migrator.current_version
  end

  before(:each) do
    FileUtils.rm_rf("db")
    FileUtils.rm("foo.db") if File.exists?("foo.db")
    ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection("sqlite3:///foo.db")
  end

  describe "db:create_migration" do
    it "aborts if NAME is not specified" do
      expect { create_migration(nil) }.to raise_error
    end

    it "creates the migration file" do
      create_migration("create_users")
      migration_file = Dir["db/migrate/*"].first
      migration_file.should match(/\d+_create_users\.rb$/)
    end
  end

  describe "db:migrate" do
    it "migrates the database" do
      current_version.should == 0
      create_migration("create_users")
      migrate
      current_version.should_not == 0
    end

    it "handles VERSION if specified" do
      current_version.should == 0
      create_migration("create_users", 1)
      create_migration("create_books", 2)
      migrate(1)
      current_version.should == 1
    end
  end

  describe "db:rollback" do
    it "rolls back the database" do
      current_version.should == 0
      create_migration("create_users")
      migrate
      current_version.should_not == 0
      rollback
      current_version.should == 0
    end

    it "handles STEP if specified" do
      current_version.should == 0
      create_migration("create_users", 1)
      create_migration("create_students", 2)
      migrate
      rollback(2)
      current_version.should == 0
    end
  end
end
