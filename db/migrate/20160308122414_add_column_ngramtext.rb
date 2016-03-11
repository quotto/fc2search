class AddColumnNgramtext < ActiveRecord::Migration
  def change
    add_column :movies, :ngramtext, :text,  null: false
  end
end
