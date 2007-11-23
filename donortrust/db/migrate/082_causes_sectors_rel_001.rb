class CausesSectorsRel001 < ActiveRecord::Migration
  def self.up
    create_table :causes_sectors,  :id => false do |t|
      t.column :cause_id,     :integer
      t.column :sector_id,    :integer   
    end
  end
  def self.down
    drop_table :causes_sectors
  end
end
