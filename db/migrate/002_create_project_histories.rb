class CreateProjectHistories < ActiveRecord::Migration
  def self.up
    create_table :project_histories do |t|
      t.column :project_id, :integer, :null => false
      t.column :date, :datetime
      t.column :cost, :float
      t.column :dollars_spent, :float
      t.column :expected_completion_date, :datetime      
      t.column :start_date, :datetime
      t.column :end_date, :datetime
      t.column :user_id, :integer  
      t.column :status_id, :integer
    end
  end

  def self.down
    drop_table :project_histories
  end
end
