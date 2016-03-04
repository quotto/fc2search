class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :movieid,null: false, index: true
      t.string :title,null: false
      t.string :url,null: false
      t.string :thumbnail
      t.integer :playtime,null: false,index: true
      t.integer :playcount, default: 0, index: true
      t.integer :albumcount, default: 0, index: true
      t.integer :commentcount, default: 0, index: true
      t.string :user, null: false
      t.string :scope, null: false
      t.string :tags, null: true
      t.datetime :upload_at, null: false
      t.timestamps null: false
    end
  end
end
