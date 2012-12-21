require 'spec_helper'
require 'sinatra/activerecord/rake'
require 'fileutils'

describe "Rake tasks" do
  include Sinatra::ActiveRecordTasks

  def schema_version
    ActiveRecord::Migrator.current_version
  end

  before(:each) do
    FileUtils.mkdir_p("tmp")
    FileUtils.rm_rf("tmp/foo.sqlite3")

    ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection("sqlite3:///tmp/foo.sqlite3")
    ActiveRecord::Migrator.migrations_paths = "tmp"
  end

  around(:each) do |example|
    ActiveRecord::Migration.verbose = false
    example.run
    ActiveRecord::Migration.verbose = true
  end

  after(:each) do
    FileUtils.rm_rf("db")
    FileUtils.rm_rf("tmp")
  end

  it "uses ActiveRecord::Migrator.migrations_paths for the migration directory" do
    ActiveRecord::Migrator.migrations_paths = "foo"
    expect {
      create_migration("create_users")
    }.to change{Dir["foo/*"].any?}.from(false).to(true)
    expect { migrate }.to change{schema_version}
    expect { rollback }.to change{schema_version}
    FileUtils.rm_rf("foo")
  end

  describe "db:create_migration" do
    it "aborts if NAME is not specified" do
      expect { create_migration(nil) }.to raise_error
    end

    it "creates the migration file" do
      create_migration("create_users")
      migration_file = Dir["tmp/*"].first
      migration_file.should match(/\d+_create_users\.rb$/)
    end
  end

  describe "db:migrate" do
    it "aborts if connection isn't established" do
      ActiveRecord::Base.remove_connection
      expect { migrate }.to raise_error(ActiveRecord::ConnectionNotEstablished)
    end

    it "migrates the database" do
      create_migration("create_users")
      expect { migrate }.to change{schema_version}
    end

    it "handles VERSION if specified" do
      create_migration("create_users", 1)
      create_migration("create_books", 2)
      expect { migrate(1) }.to change{schema_version}.to(1)
    end
  end

  describe "db:rollback" do
    it "aborts if connection isn't established" do
      ActiveRecord::Base.remove_connection
      expect { rollback }.to raise_error(ActiveRecord::ConnectionNotEstablished)
    end

    it "rolls back the database" do
      create_migration("create_users")
      expect { migrate }.to change{schema_version}.from(0)
      expect { rollback }.to change{schema_version}.to(0)
    end

    it "handles STEP if specified" do
      create_migration("create_users", 1)
      create_migration("create_students", 2)
      migrate
      expect { rollback(2) }.to change{schema_version}.to(0)
    end
  end
end
