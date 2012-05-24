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
      set :database_url, url
      database
    end

    def database
      @database ||= begin
        ActiveRecord::Base.logger = activerecord_logger
        ActiveRecord::Base.establish_connection(database_url.sub(/^sqlite/, "sqlite3"))
        ActiveRecord::Base
      end
    end

  protected

    def self.registered(app)
      app.set :activerecord_logger, Logger.new(STDOUT)
      app.helpers ActiveRecordHelper

      # re-connect if database connection dropped
      app.before { ActiveRecord::Base.verify_active_connections! }
      app.after  { ActiveRecord::Base.clear_active_connections! }
    end
  end

  register ActiveRecordExtension
end
