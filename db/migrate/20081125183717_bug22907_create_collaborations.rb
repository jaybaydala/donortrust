class Bug22907CreateCollaborations < ActiveRecord::Migration
  def self.up
		# Create the new table to richly associate a given agency to a given project
    create_table :collaborations do |t|
      t.column :project_id, :integer, :null => false
      t.column :collaborating_agency_id, :integer, :null => false
      t.column :responsibilities,  :string
    end

		# Drop the unnecessary columns in the collaborating_agencies table
		remove_column :collaborating_agencies, :project_id
		remove_column :collaborating_agencies, :responsibilities

  end

  def self.down
    drop_table :collaborations

		# Note that this will not re-insert the data that was originally present in
    # the columns
		add_column :collaborating_agencies, :project_id, :integer, :null => false
		add_column :collaborating_agencies, :responsibilities,  :string
  end
end
