#coding:utf-8;

load 'db/migrate/20160310142212_add_full_text_index_to_movies.rb'
class Tasks::NgramParser
  def self.execute
    @logger.info "remove ngramtext index" 
    AddFullTextIndexToMovies.down
    
    ngram = NGram.new({
      size: 2,
      word_separeter: ",",
      padchar: ""
    })

    movies = Movie.all
    movies.each do |movie|
      ngramtext = ngram.parse(movie.title).join(",")
      movie.ngramtext = "#{ngramtext},#{movie.tags}"
      movie.save
    end

    @logger.info "add ngram index"
    AddFullTextIndexToMovies.up
  end
end
