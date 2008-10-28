class AddNotifyGiverToGifts < ActiveRecord::Migration
  def self.up
    add_column :gifts, :notify_giver, :boolean
  end

  def self.down
    remove_column :gifts, :notify_giver
  end
end
