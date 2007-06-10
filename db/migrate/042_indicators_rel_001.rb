class IndicatorsRel001 < ActiveRecord::Migration
  def self.up
    create_table :indicators, :force => true do |t|
    t.column :target_id, :int
    t.column :description, :string
    end
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "indicators")
    end
    
  end



  def self.down
    drop_table :indicators
  end
end
