class CausesRel001 < ActiveRecord::Migration
 def self.up
   create_table :causes do |t|
        t.column :name,          :string
        t.column :description,   :string
        t.column :sector_id,     :int        
   end
end
  def self.down
      drop_table :causes
  end
end