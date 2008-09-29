class CreateParticipants < ActiveRecord::Migration
  def self.up
    create_table :participants do |t|
      t.references :team
      t.references :user
      t.string :short_name
      t.boolean :pending
      t.boolean :private
      t.text :about_participant
      t.string :picture
      t.integer :goal

      t.timestamps
    end
  end

  def self.down
    drop_table :participants
  end
end
