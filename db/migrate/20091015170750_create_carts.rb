class CreateCarts < ActiveRecord::Migration
  def self.up
    create_table :carts do |t|
      t.integer :order_id, :user_id
      t.boolean :subscription, :default => false
      t.timestamps
    end
    create_table :cart_line_items do |t|
      t.integer :cart_id
      t.string :item_type
      t.text :item_attributes
      t.timestamps
    end
  end

  def self.down
    drop_table :cart_line_items
    drop_table :carts
  end
end
