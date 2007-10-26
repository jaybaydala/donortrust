class UpdateTaxReceipts < ActiveRecord::Migration
def self.up        
    remove_column :tax_receipts, :investment_id
    add_column :tax_receipts, :gift_id, :integer
    add_column :tax_receipts, :deposit_id, :integer  
    add_column :tax_receipts, :email, :string 
  end

  def self.down
    add_column :tax_receipts, :investment_id, :integer
    remove_column :tax_receipts, :gift_id
    remove_column :tax_receipts, :deposit_id
    remove_column :tax_receipts, :email 
  end
end





