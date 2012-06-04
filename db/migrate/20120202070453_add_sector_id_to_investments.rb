class AddSectorIdToInvestments < ActiveRecord::Migration
  def self.up
    add_column :investments, :sector_id, :integer
  end

  def self.down
    remove_column :investments, :sector_id
  end
end
