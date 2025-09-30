require 'sinatra'

set :port, 3000
set :bind, '0.0.0.0'

get '/test' do
  'Ruby backend is working!'
end