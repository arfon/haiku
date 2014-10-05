require 'sinatra'
require 'mongo_mapper'
require 'active_support/all'
require './haiku.rb'

##
# Configuration for Heroku

uri = URI.parse(ENV['MONGOHQ_URL'])
MongoMapper.connection = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
MongoMapper.database = uri.path.gsub(/^\//, '')


use Rack::Auth::Basic, "Restricted Zen Area" do |username, password|
  username == 'zen' and password == 'astrozen'
end

get '/review' do
  haikus = Haiku.all
  erb :review, :locals => { :haikus => haikus }
end
