require 'sinatra/base'
require 'active_record'
require 'logger'

module Sinatra
  module ActiveRecordHelper
    def database
      settings.database
    end
  end

  module ActiveRecordExtension
    def database=(url)
      set :database_url, url
      database
    end

    def database
      @database ||= begin
        ActiveRecord::Base.logger = activerecord_logger
        url = database_url.sub(/^sqlite/, "sqlite3") rescue nil
        ActiveRecord::Base.establish_connection(url)
        ActiveRecord::Base
      end
    end

  protected

    def self.registered(app)
      app.set :activerecord_logger, Logger.new(STDOUT)
      app.set :database_url, ENV['DATABASE_URL']
      app.database if ENV['DATABASE_URL'] # Force connection if DATABASE_URL is set
      app.helpers ActiveRecordHelper

      # re-connect if database connection dropped
      app.before { ActiveRecord::Base.verify_active_connections! }
      app.after  { ActiveRecord::Base.clear_active_connections! }
    end
  end

  register ActiveRecordExtension
end
