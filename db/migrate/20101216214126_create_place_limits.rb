class CreatePlaceLimits < ActiveRecord::Migration
  def self.up
    create_table :place_limits do |t|
      t.references :campaign
      t.references :place

      t.timestamps
    end
  end

  def self.down
    drop_table :place_limits
  end
end
