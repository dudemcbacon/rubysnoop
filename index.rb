require 'sinatra'
require 'erb'

set :bind, '0.0.0.0'

get '/index' do
  @thing = 'butt'
  erb :index  
end
