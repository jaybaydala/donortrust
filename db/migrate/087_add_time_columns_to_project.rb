class AddTimeColumnsToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :created_at, :datetime
    add_column :projects, :updated_at, :datetime
  end

  def self.down
    remove_column :projects, :created_at
    remove_column :projects, :updated_at
  end
end
