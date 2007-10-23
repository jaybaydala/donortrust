class AddTimeColumnsToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :created_at, :datetime
    add_column :projects, :updated_at, :datetime
    Project.create_versioned_table
  end

  def self.down
    remove_column :projects, :created_at
    remove_column :projects, :updated_at
    Project.drop_versioned_table
  end
end
