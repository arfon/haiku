class Haiku
  include MongoMapper::Document

  key :url, String
  key :body, String
  key :status, String, :default => 'unpublished'
  key :published_at, Time

  timestamps!

  scope :published, :status => 'published'

  def inline_formatted
    body.strip.split("\n").map(&:strip).join(', ')
  end
end
