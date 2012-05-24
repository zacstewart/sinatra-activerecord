require 'spec_helper'
require 'rake'
require 'sinatra/activerecord/rake'

module RakeTaskHelpers
  def invoke_task(rake_task, params = {})
    case rake_task.to_sym
    when :create_migration
      begin
        ENV['NAME'] = params[:name]
        @rake["db:create_migration"].invoke
        migration_file = Dir["db/migrate/*"].last
        File.basename(migration_file)[/^\d+/].to_i # version
      ensure
        ENV.delete('NAME')
        @rake["db:create_migration"].reenable
      end
    when :migrate
      begin
        ENV['VERSION'] = (params[:version] ? params[:version].to_s : nil)
        @rake["db:migrate"].invoke
        current_version
      ensure
        ENV.delete('VERSION')
        @rake["db:migrate"].reenable
      end
    when :rollback
      begin
        ENV['STEP'] = params[:step]
        @rake["db:rollback"].invoke
        current_version
      ensure
        ENV.delete('STEP')
        @rake["db:rollback"].reenable
      end
    else
      raise "No rake task named '#{rake_task}'"
    end
  end

  def current_version
    ActiveRecord::Migrator.current_version
  end
end

describe "rake tasks" do
  include RakeTaskHelpers

  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require 'sinatra/activerecord/rake_tasks'

    # disable ActiveRecord logging
    app = Class.new(MockSinatraApp)
    app.activerecord_logger = nil
    app.set :database, "sqlite:///foo.db"
  end

  around(:each) do |example|
    # disable ActiveRecord logging
    $stdout = $stderr = StringIO.new
    example.call
    $stdout, $stderr = STDOUT, STDERR
  end

  after(:each) do
    FileUtils.rm_rf("db")
    FileUtils.rm("foo.db") rescue nil
  end

  describe "db:create_migration" do
    it "aborts if NAME is not specified" do
      expect { invoke_task(:create_migration) }.to raise_error
    end

    it "creates the migration file" do
      invoke_task(:create_migration, :name => "create_users")
      migration_file = Dir["db/migrate/*"].first
      migration_file.should_not be_nil
      migration_file.should match(/\d+_create_users\.rb$/)
    end
  end

  describe "db:migrate" do
    it "migrates the database" do
      current_version.should == 0
      version = invoke_task(:create_migration, :name => "create_users")
      invoke_task(:migrate).should == version
      invoke_task(:rollback)
    end

    it "handles VERSION if specified" do
      first_version = invoke_task(:create_migration, :name => "create_users")
      second_version = invoke_task(:create_migration, :name => "create_users")
      invoke_task(:migrate, :version => first_version).should == first_version
    end
  end

  describe "db:rollback" do
    it "exists" do
      expect { invoke_task(:rollback) }.to_not raise_error
    end
  end
end
