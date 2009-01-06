class AddApprovedToCollaboratingAgencies < ActiveRecord::Migration
  def self.up
    # New collaborating agencies are not approved by default
    add_column :collaborating_agencies, :approved, :boolean, :default => false, :null => false

    # Assume everything present in the database before this migration is marked 
    # as "approved"
    CollaboratingAgency.update_all ["approved = ?", true]
  end

  def self.down
    remove_column :collaborating_agencies, :approved
  end
end
