class AddTokenAndUnsubscribeToProjectPois < ActiveRecord::Migration
  def self.up
    add_column :project_pois, :token, :string
    add_column :project_pois, :unsubscribed, :boolean, :default => false
  end

  def self.down
    remove_column :project_pois, :token
    remove_column :project_pois, :unsubscribed
  end
end
