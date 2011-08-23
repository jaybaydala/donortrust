class CreatePreferredSectors < ActiveRecord::Migration
  def self.up
    create_table :preferred_sectors do |t|
      t.references :user
      t.references :sector

      t.timestamps
    end
  end

  def self.down
    drop_table :preferred_sectors
  end
end
