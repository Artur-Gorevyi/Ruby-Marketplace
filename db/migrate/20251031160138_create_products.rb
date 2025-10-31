class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.text :short_description
      t.text :description
      t.decimal :price
      t.string :category
      t.string :color

      t.timestamps
    end
  end
end
