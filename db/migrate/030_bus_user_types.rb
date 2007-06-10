class BusUserTypes < ActiveRecord::Migration
  def self.up
    create_table :bus_user_types, :force => true do |t|
      t.column :name,                      :string
    end    

    
  end

  def self.down
    drop_table :bus_user_types
  end
end
