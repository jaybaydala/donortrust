class MeasurementsRel001 < ActiveRecord::Migration
  def self.up
    create_table "measurements", :force => true do |t|
    t.column :indicator_measurement_id,       :int,  :null => false
     t.column :value,              :string,  :null => false
     t.column :comment,          :string,  :null => true
    end

  if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "measurements")
    end
  end


  def self.down
    drop_table "measurements"
  end
end