class CreateUnpaidParticipantsTable < ActiveRecord::Migration
  def self.up
    create_table :unpaid_participants do |t|
      t.integer :user_id
      t.integer :team_id
      t.integer :registration_fee_id
      t.string  :short_name
      t.boolean :private
      t.boolean :pending
      t.text    :about_participant
      t.string  :picture
      t.integer :goal
    end
  end

  def self.down
    drop_table :unpaid_participants
  end
end
