class ECardsRel001 < ActiveRecord::Migration
  def self.up
    create_table :e_cards do |t|
      t.column :name,     :string
      t.column :credit,   :string  
      t.column :file,     :text     
    end
  end
  def self.down
    drop_table :e_cards
  end
end
