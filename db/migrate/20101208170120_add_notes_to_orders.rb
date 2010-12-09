class AddNotesToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :notes, :text
  end

  def self.down
    remove_column :orders, :notes
  end
end
