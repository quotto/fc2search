class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :movieid,null: false, index: true
      t.string :title,null: false
      t.string :url,null: false
      t.string :thumbnail
      t.integer :playtime,null: false
      t.integer :playcount, default: 0
      t.integer :albumcount, default: 0
      t.integer :commentcount, default: 0
      t.string :user, null: false
      t.string :scope, null: false
      t.datetime :upload_at, null: false
      t.timestamps null: false
    end
  end
end
