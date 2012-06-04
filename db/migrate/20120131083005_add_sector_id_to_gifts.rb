class AddSectorIdToGifts < ActiveRecord::Migration
  def self.up
    add_column :gifts, :sector_id, :integer
  end

  def self.down
    remove_column :gifts, :sector_id
  end
end
