class PlaceSectorsRel001 < ActiveRecord::Migration
  def self.up
    create_table :place_sectors do |t|
      t.column :place_id,     :integer
      t.column :sector_id,    :integer   
      t.column :content,      :string
    end
  end
  def self.down
    drop_table :place_sectors
  end
end
