class AddPublicToPledges < ActiveRecord::Migration
  def self.up
    add_column :pledges, :public, :boolean
    add_column :pledges, :pledger_email, :string
  end

  def self.down
    remove_column :pledges, :public
    remove_column :pledges, :pledger_email
  end
end
