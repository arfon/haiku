require 'active_support/all'

class Haiku
  include MongoMapper::Document

  key :url, String
  key :body, String
  key :random, Float
  key :status, String, :default => 'unpublished'
  key :published_at, Time

  timestamps!

  scope :published, :status => 'published', :order => 'created_at DESC'
  scope :sorted, :order => 'created_at DESC'
  scope :random, lambda { |number| where(:random.gte => number) }

  def new_haiku?
    created_at > 12.hours.ago
  end

  def inline_formatted
    body.strip.split("\n").map(&:strip).join(', ')
  end

  def published?
    status == 'published'
  end
end
