class AddNotifyToGifts < ActiveRecord::Migration
  def self.up
    add_column :gifts, :notify, :boolean
  end

  def self.down
    remove_column :gifts, :notify
  end
end
