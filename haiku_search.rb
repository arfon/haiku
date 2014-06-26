require 'active_support/all'

def log_and_monitor(opname)
  puts "Starting #{opname}"
  starttime = Time.now
  yield
  endtime = Time.now
  puts "Finished #{opname} - ran for #{endtime - starttime} s"
end

def haiku_search(bookfile, arpabetfile)
  dictionary = File.open(arpabetfile, 'r')
  book = File.open(bookfile, 'r')
  book_to_string = words_in_book = book_words = syls = nil

  log_and_monitor("processing books") do

    book_to_string = book.read()
    words_in_book = book_to_string.gsub(/[^A-Za-z\s]/, '').split(' ')
    book_words = words_in_book.each {|word| word.upcase!}
    syls = {}
  end

  log_and_monitor("processing cmudict") do
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
      puts titlecase.join(' ')
      puts '----------------------'
    end
  end
end
end

haiku_search(ARGV[0], 'cmudict.txt')

