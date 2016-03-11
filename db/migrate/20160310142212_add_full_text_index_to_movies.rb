class AddFullTextIndexToMovies < ActiveRecord::Migration
  def self.up
    add_index :movies, :ngramtext, type: :fulltext
  end
  def self.down
    remove_index :movies,:ngramtext
  end
end
