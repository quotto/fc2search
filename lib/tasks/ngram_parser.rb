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

    total = Movie.count
    cycle = (total.to_f / 1000.0).ceil
    count = 0
    for i in 0..cycle do 
      Movie.transaction do
        movies = Movie.all.limit(1000).offset(i * 1000)
        movies.each do |movie|
          ngramtext = ngram.parse(movie.title).join(",")
          movie.ngramtext = "#{ngramtext},#{movie.tags}"
          movie.save
        end     
        count = count + 1
        puts "#{count}/#{total}"
      end
    end

    puts "add ngram index"
    AddFullTextIndexToMovies.up
  end
end
