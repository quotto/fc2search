#coding:utf-8;

load 'db/migrate/20160310142212_add_full_text_index_to_movies.rb'
class Tasks::NgramParser
  def self.execute
    puts "remove ngramtext index" 
    AddFullTextIndexToMovies.down
    
    ngram = NGram.new({
      size: 2,
      word_separeter: ",",
      padchar: ""
    })

    movies = Movie.all
    movies.each_with_index do |index,movie|
      ngramtext = ngram.parse(movie.title).join(",")
      movie.ngramtext = "#{ngramtext},#{movie.tags}"
      movie.save
      puts "#{index}/#{movies.size}"
    end

    puts "add ngram index"
    AddFullTextIndexToMovies.up
  end
end
