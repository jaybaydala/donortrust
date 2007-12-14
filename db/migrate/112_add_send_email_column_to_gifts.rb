class AddSendEmailColumnToGifts < ActiveRecord::Migration
  def self.up
    add_column :gifts, :send_email, :boolean, :default => 1
  end

  def self.down
    remove_column :gifts, :send_email
  end
end
