class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.column :program_id, :integer
      t.column :category_id, :integer
      t.column :name, :string, :null => false
      t.column :description, :text
      t.column :cost, :float
      t.column :dollars_spent, :float
      t.column :expected_completion_date, :datetime
      t.column :start_date, :datetime
      t.column :end_date, :datetime
      t.column :status_id, :integer
      t.column :contact_id, :integer
      t.column :location_id, :integer
    end
  end

  def self.down
    drop_table :projects
  end
end
