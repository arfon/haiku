require 'xmlsimple'
require 'net/http'
require 'active_support/all'
require 'mongo_mapper'
require './haiku.rb'
require 'pry'

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
  if Haiku.find_by_url(url)
    puts "Already parsed #{url}"
  else
    Haiku.create(:url => url, :body => haiku)
  end

  puts "#{index+1}/#{paper_count}"
end
