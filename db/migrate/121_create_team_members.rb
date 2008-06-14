class CreateTeamMembers < ActiveRecord::Migration
  def self.up
    create_table :team_members do |t|
      t.references :team
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :team_members
  end
end
