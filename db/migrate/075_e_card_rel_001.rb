class ECardRel001 < ActiveRecord::Migration
  def self.up
    create_table :e_card do |t|
      t.column :name,     :text
      t.column :credit,   :text   
      t.column :image,    :blob  
    end
  end
  def self.down
    drop_table :e_card
  end
end
