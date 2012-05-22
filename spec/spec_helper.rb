require 'sinatra/base'
require 'sinatra/activerecord'

class MockSinatraApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension
end
