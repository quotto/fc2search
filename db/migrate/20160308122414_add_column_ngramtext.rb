class AddColumnNgramtext < ActiveRecord::Migration
  def change
    add_column :movies, :ngramtext, :string,  null: false
  end
end
