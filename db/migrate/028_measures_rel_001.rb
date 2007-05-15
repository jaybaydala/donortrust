require 'active_record/fixtures'

class MeasuresRel001 < ActiveRecord::Migration
  def self.up
    create_table :measures do |t|
      t.column :measure_category_id, :int
      t.column :quantity, :int
      t.column :measure_date, :date
      t.column :user_id, :int
    end
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "measures")
    end
  end
  
  def self.down
    drop_table :measures
  end
end