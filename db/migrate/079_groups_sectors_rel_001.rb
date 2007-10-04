class GroupsSectorsRel001 < ActiveRecord::Migration
  def self.up
    create_table :groups_sectors, :id => false do |t|
      t.column :group_id, :int
      t.column :sector_id, :int
    end
    add_index :groups_sectors, [:group_id, :sector_id] 
    add_index :groups_sectors, :sector_id 
  end

  def self.down
    drop_table :groups_sectors
  end
end
