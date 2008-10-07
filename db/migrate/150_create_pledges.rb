class CreatePledges < ActiveRecord::Migration
  def self.up
    create_table :pledges do |t|

      t.references :participant
      t.references :team
      t.references :campaign
      t.references :order
      t.references :user

      t.decimal :amount

      t.boolean :paid
      t.boolean :released

      t.timestamps
    end

    add_index "pledges",      ["order_id"], :name => "order_id"
  end

  def self.down
    drop_table :pledges
  end
end
