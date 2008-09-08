class CreatePledges < ActiveRecord::Migration
  def self.up
    create_table :pledges do |t|
      t.references :participant
      t.references :deposit
      t.boolean :released
      t.timestamps
    end
  end

  def self.down
    drop_table :pledges
  end
end
