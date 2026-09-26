class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :external_id,   null: false
      t.string :title,         null: false
      t.text :description
      t.string :image_url
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :billetto_url
      t.string :location
      t.string :organiser_name
      t.boolean :available,    null: false, default: true
      t.integer :like_count,   null: false, default: 0
      t.integer :dislike_count, null: false, default: 0

      t.timestamps
    end
    add_index :events, :external_id, unique: true
  end
end
