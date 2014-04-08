require 'sinatra'

set :bind, '0.0.0.0'

get '/index' do
  "Hello world!"
end
