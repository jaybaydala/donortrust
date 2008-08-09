class AddPartnerFieldsToKeyMeasuresAndFinancialSources < ActiveRecord::Migration
  def self.up
    add_column :financial_sources, :partner_id, :integer
    add_column :key_measures, :partner_id, :integer
  end

  def self.down
    remove_column :key_measures, :partner_id
    remove_column :financial_sources, :partner_id
  end
end
