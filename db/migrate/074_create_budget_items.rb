class CreateBudgetItems < ActiveRecord::Migration
  def self.up
    create_table :budget_items do |t|
      t.column :project_id, :integer #, :null => false
      t.column :description, :string
      t.column :cost, :decimal, :precision => 8, :scale => 2, :default => 0
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime
    end
  end

  def self.down
    drop_table :budget_items
  end
end
