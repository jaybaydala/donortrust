class KeyMeasureDataRel001 < ActiveRecord::Migration
  def self.up
    create_table "key_measure_data", :force => true do |t|
      t.column :key_measure_id,   :int,     :null => false
      t.column :value,                      :string,  :null => false
      t.column :comment,                    :string,  :null => true
      t.column :date,                       :date,    :null => true
    end

 # if (ENV['RAILS_ENV'] == 'development')
 #     directory = File.join(File.dirname(__FILE__), "dev_data")
 #     Fixtures.create_fixtures(directory, "key_measure_data")
 #   end
  end

  def self.down
    drop_table "key_measure_data"
  end
end