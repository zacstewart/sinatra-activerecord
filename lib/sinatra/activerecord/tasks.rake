require 'rake'

namespace :db do
  desc "create an ActiveRecord migration in ./db/migrate"
  task :create_migration do
    Sinatra::ActiveRecordTasks.create_migration(ENV["NAME"], ENV["VERSION"])
  end

  desc "migrate the database (use version with VERSION=n)"
  task :migrate do
    Sinatra::ActiveRecordTasks.migrate(ENV["VERSION"])
  end

  desc "roll back the migration (use steps with STEP=n)"
  task :rollback do
    Sinatra::ActiveRecordTasks.rollback(ENV["STEP"])
  end
end
