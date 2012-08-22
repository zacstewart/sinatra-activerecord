require 'active_record'
require 'active_support/core_ext/string/strip'
require 'fileutils'

module Sinatra
  module ActiveRecordTasks
    extend self

    def create_migration(migration_name, version = nil)
      raise "No NAME specified. Example usage: `rake db:create_migration NAME=create_users`" if migration_name.nil?

      migration_number = version || Time.now.utc.strftime("%Y%m%d%H%M%S")
      migration_file = File.join(migrations_dir, "#{migration_number}_#{migration_name}.rb")
      migration_class = migration_name.split("_").map(&:capitalize).join

      FileUtils.mkdir_p(migrations_dir)
      File.open(migration_file, 'w') do |file|
        file.write <<-MIGRATION.strip_heredoc
          class #{migration_class} < ActiveRecord::Migration
            def up
            end

            def down
            end
          end
        MIGRATION
      end
    end

    def migrate(version = nil)
      silence_activerecord do
        migration_version = version ? version.to_i : version
        ActiveRecord::Migrator.migrate(migrations_dir, migration_version)
      end
    end

    def rollback(step = nil)
      silence_activerecord do
        migration_step = step ? step.to_i : 1
        ActiveRecord::Migrator.rollback(migrations_dir, migration_step)
      end
    end

    private

    def migrations_dir
      "db/migrate"
    end

    def silence_activerecord(&block)
      old_logger = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = nil
      yield if block_given?
      ActiveRecord::Base.logger = old_logger
    end
  end
end

load 'sinatra/activerecord/tasks.rake'
