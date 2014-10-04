require 'sinatra'
require 'mongo_mapper'
require 'active_support/all'
##
# Haiku class - this takes the Haikus generated in the rake task and adds them
# to the database

class Haiku
  include MongoMapper::Document

  key :arxiv_id, String
  key :url, String
  key :body, String
  key :status, String, :default => 'unpublished'
  key :published_at, Time

  timestamps!

  scope :published, :status => 'published'
end

##
# Configuration for Heroku

configure do
  MongoMapper.setup({'production' => {'uri' => ENV['MONGOHQ_URL']}}, 'production')
end

use Rack::Auth::Basic, "Restricted Zen Area" do |username, password|
  username == 'zen' and password == 'astrozen'
end

get '/review' do
end
