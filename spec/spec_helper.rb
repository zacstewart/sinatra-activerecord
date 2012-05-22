require 'sinatra/base'
require 'sinatra/activerecord'

RSpec.configure do |c|
  c.fail_fast = true
end

class MockSinatraApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension
end
