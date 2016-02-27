class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :movieid, null: false, index: true
      t.string :tag, null: false
      t.timestamps null: false
    end
  end
end
