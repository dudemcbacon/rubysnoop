require 'sinatra'
require 'erb'

set :bind, '0.0.0.0'

get '/index' do
  @thing = 'butt'
  erb :index  
end

post '/scan' do
  "You wanted to scan '#{params[:address]}'."
end
