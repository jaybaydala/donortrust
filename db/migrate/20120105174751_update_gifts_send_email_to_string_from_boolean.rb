class UpdateGiftsSendEmailToStringFromBoolean < ActiveRecord::Migration
  def self.up
    change_column :gifts, :send_email, :string, :default => "yes"
  end

  def self.down
    change_column :gifts, :send_email, :boolean, :default => true
  end
end
