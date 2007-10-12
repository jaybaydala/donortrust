class MeasuresRel001 < ActiveRecord::Migration
  def self.up
    create_table :measures, :force => true do |t|
    t.column :millennium_goal_id, :int
    t.column :description, :string
    t.column :deleted_at, :datetime
    end
    
  #  if (ENV['RAILS_ENV'] == 'development')
  #    directory = File.join(File.dirname(__FILE__), "dev_data")
  #    Fixtures.create_fixtures(directory, "measures")
  #  end
    
  end



  def self.down
    drop_table :measures
  end
end
