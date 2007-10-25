class AddLocationFieldsToGroup < ActiveRecord::Migration
  def self.up
    remove_column :groups, :place_id
    add_column :groups, :city, :string
    add_column :groups, :province, :string
    add_column :groups, :country, :string
  end

  def self.down
    add_column :groups, :place_id, :integer
    remove_column :groups, :city
    remove_column :groups, :province
    remove_column :groups, :country
  end
end
