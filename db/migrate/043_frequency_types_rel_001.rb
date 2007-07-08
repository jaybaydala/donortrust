class FrequencyTypesRel001 < ActiveRecord::Migration
  def self.up
    create_table "frequency_types", :force => true do |t|
      t.column :name,              :string,  :null => false
    end
 

  if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "frequency_types")
    end
  end

  def self.down
    drop_table "frequency_types"
  end
end