class UpdateAmountOnPledges < ActiveRecord::Migration
  def self.up
    change_column :pledges, :amount, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    change_column :pledges, :amount, :decimal
  end
end
