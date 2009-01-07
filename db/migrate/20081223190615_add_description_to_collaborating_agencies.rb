class AddDescriptionToCollaboratingAgencies < ActiveRecord::Migration
  def self.up
    add_column :collaborating_agencies, :description, :text
  end

  def self.down
    remove_column :collaborating_agencies, :description, :text
  end
end
