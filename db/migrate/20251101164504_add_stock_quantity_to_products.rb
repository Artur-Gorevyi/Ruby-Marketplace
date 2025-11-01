class AddStockQuantityToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :stock_quantity, :integer
  end
end
