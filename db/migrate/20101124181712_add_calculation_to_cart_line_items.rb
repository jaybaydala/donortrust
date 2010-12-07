class AddCalculationToCartLineItems < ActiveRecord::Migration
  def self.up
    add_column :cart_line_items, :donation, :boolean, :default => false
    add_column :cart_line_items, :auto_calculate_amount, :boolean, :default => false
    add_column :cart_line_items, :percentage, :integer, :default => 15
  end

  def self.down
    remove_column :cart_line_items, :percentage
    remove_column :cart_line_items, :auto_calculate_amount
    remove_column :cart_line_items, :donation
  end
end
