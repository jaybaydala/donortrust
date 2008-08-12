class AddReceivedDateToFinancialSources < ActiveRecord::Migration
  def self.up
    add_column :financial_sources, :received_on, :date
  end

  def self.down
    remove_column :financial_sources, :received_on
  end
end
