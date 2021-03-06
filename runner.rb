require 'active_support/all'
require 'mongo_mapper'
require './haiku'
require 'net/http'
require 'twitter'
require 'xmlsimple'

##
# Connect to Twitter to send a DM when the job has been run

twitter = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

##
# Configuration for Heroku

uri = URI.parse(ENV['MONGOHQ_URL'])
MongoMapper.connection = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
MongoMapper.database = uri.path.gsub(/^\//, '')

##
# See https://github.com/jnxpn/haiku_generator

def haiku_search(incoming, arpabetfile)
  dictionary = File.open(arpabetfile, 'r')
  book_to_string = words_in_book = book_words = syls = nil

  book_to_string = incoming
  words_in_book = book_to_string.gsub(/[^A-Za-z\s]/, '').split(' ')
  book_words = words_in_book.each {|word| word.upcase!}
  syls = {}

  dictionary.each_line do |line|
    word, phonemes = line.split('  ')
    syllables = phonemes.split(' ')
    total_syls = 0
    syllables.each do |syl|
      if syl =~ /\d/
        total_syls += 1
      end
    end
    syls[word] = total_syls
  end


  book_words.each_index do |i|
    j = i
    syls_per_line = [5,7,5]
    haiku = []
    success = true
    bad_ending_words = ['THE', 'AND', 'OR', 'A', 'OF', 'TO', 'BUT']

    syls_per_line.each do |syl|
      remaining_syl = syl
      while (remaining_syl > 0)  &&  (syls[book_words[j]] != nil) && (syls[book_words[j]] <= remaining_syl) && (syls[book_words[j]] > 0)
        haiku << book_words[j]
        remaining_syl -= syls[book_words[j]]
        j += 1
      end
      if remaining_syl != 0
        success = false
        break
      end
      haiku << "\n"
    end

    if success == true && !(bad_ending_words.include?(haiku[-2]))
      titlecase = []
      haiku.each do |h|
        if h == "\n"
          titlecase << h
        else
          titlecase << h.titlecase
        end
      end
      return titlecase.join(' ')
    end
  end
end


url = 'http://export.arxiv.org/rss/astro-ph'
xml_data = Net::HTTP.get_response(URI.parse(url)).body

data = XmlSimple.xml_in(xml_data)

puts "Working with #{paper_count = data['item'].count} papers"

data['item'].each_with_index do |paper, index|
  abstract = paper['description'].first['content']
  url = paper['link'].first

  haiku = haiku_search(abstract, 'cmudict.txt')

  next if haiku.is_a? Array
  next if Haiku.find_by_url(url)

  Haiku.create(:url => url, :body => haiku)

  puts "#{index+1}/#{paper_count}"
end

twitter.create_direct_message("@vrooje ", "Yo @vrooje , I've just processed #{paper_count} papers: http://zen.arfon.org/review")
