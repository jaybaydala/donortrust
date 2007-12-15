class FinancialSourcesRel001 < ActiveRecord::Migration
  def self.up
    create_table :financial_sources do |t|
      t.column :project_id,     :integer
      t.column :source,         :string  
      t.column :amount,         :float     
    end
  end
  def self.down
    drop_table :financial_sources
  end
end

