class CreateUrls < ActiveRecord::Migration[5.1]
  def change
    create_table :urls do |t|
      t.text :longUrl, null: false
      t.string :url, null: false, unique: true
    end
  end
end
