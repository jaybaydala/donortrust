class CausesRel001 < ActiveRecord::Migration
  def self.up
    create_table :causes, :force => true do |t|
      t.column :name,       :string 
      t.column :description, :text
      t.column :deleted_at, :datetime
     
    end
  end

  def self.down
    drop_table :causes
  end
  
end