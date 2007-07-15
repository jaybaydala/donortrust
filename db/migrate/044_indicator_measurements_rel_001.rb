class IndicatorMeasurementsRel001 < ActiveRecord::Migration
  def self.up
    create_table "indicator_measurements", :force => true do |t|
      t.column :project_id,              :int,  :null => false
      t.column :indicator_id,       :int,  :null => false
      t.column :frequency_type_id,       :int,  :null => false
      t.column :units,              :string,  :null => false
    end
 
  if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "indicator_measurements")
    end
  end

  def self.down
    drop_table "indicator_measurements"
  end
end