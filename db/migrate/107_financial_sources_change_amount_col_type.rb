class FinancialSourcesChangeAmountColType < ActiveRecord::Migration
  def self.up
    change_column(:financial_sources, :amount, :string) 
  end

  def self.down
    change_column(:financial_sources, :amount, :float) 
    
  end
end