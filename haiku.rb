require 'active_support/all'

class Haiku
  include MongoMapper::Document

  key :url, String
  key :body, String
  key :status, String, :default => 'unpublished'
  key :published_at, Time

  timestamps!

  scope :published, :status => 'published', :order => 'created_at DESC'
  scope :sorted, :order => 'created_at DESC'

  def new?
    created_at > 1.day.ago
  end

  def inline_formatted
    body.strip.split("\n").map(&:strip).join(', ')
  end

  def published?
    status == 'published'
  end
end
