require 'uri'
require 'time'
require 'sinatra/base'
require 'active_record'
require 'logger'

module Sinatra
  module ActiveRecordHelper
    def database
      options.database
    end
  end

  module ActiveRecordExtension
    def database=(url)
      @database = nil
      set :database_url, url
      database
    end

    def database
      @database ||= begin
        ActiveRecord::Base.logger = activerecord_logger
        ActiveRecord::Base.establish_connection(fixed_database_url)
        ActiveRecord::Base
      end
    end

  protected

    def fixed_database_url
      database_url.sub('sqlite', 'sqlite3')
    end

    def self.registered(app)
      app.set :database_url, lambda { ENV['DATABASE_URL'] || "sqlite://#{environment}.db" }
      app.set :database_extras, Hash.new
      app.set :activerecord_logger, Logger.new(STDOUT)
      app.database # force connection
      app.helpers ActiveRecordHelper

      app.before do
        # re-connect if database connection dropped
        ActiveRecord::Base.verify_active_connections!
      end

      app.after do
        ActiveRecord::Base.clear_active_connections!
      end
    end
  end

  register ActiveRecordExtension
end
