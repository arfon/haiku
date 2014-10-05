require 'active_support/all'
require 'mongo_mapper'
require 'sinatra'
require 'twitter'
require './haiku.rb'
require 'pry'

##
# Configuration for Heroku

uri = URI.parse(ENV['MONGOHQ_URL'])
MongoMapper.connection = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
MongoMapper.database = uri.path.gsub(/^\//, '')

twitter = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

def authorized?
  @auth ||=  Rack::Auth::Basic::Request.new(request.env)
  @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['USERNAME'], ENV['PASSWORD']]
end

def protected!
  unless authorized?
    response['WWW-Authenticate'] = %(Basic realm="Restricted Zen Area")
    throw(:halt, [401, "Oops... we need your login name & password\n"])
  end
end

get '/' do
  "Zen"
end

get '/review' do
  protected!
  haikus = Haiku.all
  erb :review, :locals => { :haikus => haikus }
end

##
# Post to Twitter like this:
#
# This Paper We Give
#  A Detailed Analysis
#  Of The Expected

# #astrohaiku http://arxiv.org/abs/1406.6384

get '/tweet/:id' do
  protected!
  haiku = Haiku.find(params[:id])

  begin
    twitter.update("#{haiku.body} \n #astrohaiku #{haiku.url}")
    haiku.status = 'published'
    haiku.save
  rescue Twitter::Error => e
    puts "Oh noes!"
  end

  redirect to('/review')
end
