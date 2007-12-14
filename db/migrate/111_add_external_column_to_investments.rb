class  AddExternalColumnToInvestments < ActiveRecord::Migration
  def self.up
    add_column :investments, :external, :boolean
  end

  def self.down
    remove_column :investments, :external
  end
end
