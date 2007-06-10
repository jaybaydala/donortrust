class MillenniumDevelopmentGoalsRel001 < ActiveRecord::Migration
  def self.up
    create_table :millennium_development_goals, :force => true do |t|
      t.column :description, :string
     
    end
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "millennium_development_goals")
    end
  end

  def self.down
    drop_table :millennium_development_goals
  end
  
end