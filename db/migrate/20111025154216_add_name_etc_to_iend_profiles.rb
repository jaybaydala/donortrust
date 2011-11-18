class AddNameEtcToIendProfiles < ActiveRecord::Migration
  def self.up
    add_column :iend_profiles, :name, :boolean, :default => false
    add_column :iend_profiles, :picture, :boolean, :default => false
    add_column :iend_profiles, :preferred_poverty_sectors, :boolean, :default => true
    change_column_default :iend_profiles, :location, false
  end

  def self.down
    change_column_default :iend_profiles, :location, true
    remove_column :iend_profiles, :preferred_poverty_sectors
    remove_column :iend_profiles, :picture
    remove_column :iend_profiles, :name
  end
end
