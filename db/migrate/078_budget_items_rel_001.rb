class BudgetItemsRel001 < ActiveRecord::Migration
 def self.up
    create_table :budget_items do |t|
      t.column :project_id,   :integer
      t.column :description,  :string  
      t.column :cost,         :float     
      t.column :created_at,   :datetime
      t.column :updated_at,   :datetime 
      t.column :deleted_at,   :datetime             
    end
  end
  def self.down
    drop_table :budget_items
  end
end
