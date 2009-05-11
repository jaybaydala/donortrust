class AddAnonymousToPledges < ActiveRecord::Migration
  def self.up
    add_column "pledges", "anonymous", :boolean
    add_column "pledges", "pledger", :string
  end

  def self.down
    remove_column "pledges", "anonymous"
    remove_column "pledges", "pledger"
  end
end
