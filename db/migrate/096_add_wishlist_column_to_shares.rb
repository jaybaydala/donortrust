class AddWishlistColumnToShares < ActiveRecord::Migration
  def self.up
    add_column :shares, :wishlist, :boolean
  end

  def self.down
    remove_column :shares, :wishlist
  end
end
