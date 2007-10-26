class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
    end
  end

  def self.down
    drop_table :invitations
  end
end
