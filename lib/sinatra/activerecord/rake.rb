require 'active_record'
require 'fileutils'

namespace :db do
  desc "migrate the database"
  task :migrate do
    version = (ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    ActiveRecord::Migrator.migrate 'db/migrate', version
  end

  desc "create an ActiveRecord migration in ./db/migrate"
  task :create_migration do
    name = ENV['NAME']
    if name.nil?
      abort "No NAME specified. Example usage: `rake db:create_migration NAME=create_users`"
    end

    migrations_dir = File.join("db", "migrate")
    version = ENV["VERSION"] || Time.now.utc.strftime("%Y%m%d%H%M%S")
    filename = "#{version}_#{name}.rb"
    migration_name = name.split("_").map(&:capitalize).join

    FileUtils.mkdir_p(migrations_dir)

    File.open(File.join(migrations_dir, filename), 'w') do |file|
      file.write <<-MIGRATION.strip_heredoc
        class #{migration_name} < ActiveRecord::Migration
          def up
          end

          def down
          end
        end
      MIGRATION
    end
  end
end
