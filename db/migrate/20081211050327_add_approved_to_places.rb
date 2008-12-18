class AddApprovedToPlaces < ActiveRecord::Migration
  def self.up
    # New places are not approved by default
    add_column :places, :approved, :boolean, :default => false, :null => false

    # Assume everything present in the database before this migration is marked 
    # as "approved"
    Place.update_all ["approved = ?", true]
  end

  def self.down
    remove_column :places, :approved
  end
end
