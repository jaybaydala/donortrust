class ECardsRel001 < ActiveRecord::Migration
  def self.up
    create_table :e_cards do |t|
      t.column :name,      :string
      t.column :credit,    :string  
      t.column :small,     :string     
      t.column :medium,    :string     
      t.column :large,     :string     
      t.column :printable, :string     
    end
  end
  def self.down
    drop_table :e_cards
  end
end
