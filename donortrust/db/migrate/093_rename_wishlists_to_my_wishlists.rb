class RenameWishlistsToMyWishlists < ActiveRecord::Migration
  def self.up
    rename_table 'wishlists', 'my_wishlists'
  end

  def self.down
    rename_table 'my_wishlists', 'wishlists'
  end
end
