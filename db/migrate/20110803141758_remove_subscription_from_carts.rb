class RemoveSubscriptionFromCarts < ActiveRecord::Migration
  def self.up
    remove_column :carts, :subscription
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
