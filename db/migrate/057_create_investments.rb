class CreateInvestments < ActiveRecord::Migration
  def self.up
    create_table :investments do |t|
    end
  end

  def self.down
    drop_table :investments
  end
end
