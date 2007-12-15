class ChangePlaceExternalColumnsToBigint < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE places CHANGE you_tube_reference you_tube_reference bigint(19) DEFAULT NULL"
    execute "ALTER TABLE places CHANGE flickr_reference flickr_reference bigint(19) DEFAULT NULL"
    execute "ALTER TABLE places CHANGE facebook_group_id facebook_group_id bigint(19) DEFAULT NULL"
  end

  def self.down
    change_column :places, :you_tube_reference, :integer, :limit => 15
    change_column :places, :flickr_reference,   :integer, :limit => 15
    change_column :places, :facebook_group_id,  :integer, :limit => 15
  end
end
