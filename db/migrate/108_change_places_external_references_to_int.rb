class ChangePlacesExternalReferencesToInt < ActiveRecord::Migration
  def self.up
    change_column :places, :you_tube_reference, :integer, :limit => 15
    change_column :places, :flickr_reference,   :integer, :limit => 15
    change_column :places, :facebook_group_id,  :integer, :limit => 15
  end

  def self.down
    change_column :places, :flickr_reference,   :decimal, :precision => 15, :scale => 2
    change_column :places, :facebook_group_id,  :decimal, :precision => 15, :scale => 2
    change_column :places, :you_tube_reference, :decimal, :precision => 15, :scale => 2
  end
end
