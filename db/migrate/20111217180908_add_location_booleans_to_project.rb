class AddLocationBooleansToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :ca, :boolean, :default => true
    add_column :projects, :us, :boolean, :default => true
  end

  def self.down
    remove_column :projects, :us
    remove_column :projects, :ca
  end
end
