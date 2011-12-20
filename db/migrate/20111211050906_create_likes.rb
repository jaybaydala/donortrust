class CreateLikes < ActiveRecord::Migration
  def self.up
    create_table :likes do |t|
      t.integer :likeable_id
      t.string :likeable_type
      t.string :network

      t.timestamps
    end
  end

  def self.down
    drop_table :likes
  end
end
