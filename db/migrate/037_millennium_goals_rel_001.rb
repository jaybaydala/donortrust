class MillenniumGoalsRel001 < ActiveRecord::Migration
  def self.up
    create_table :millennium_goals, :force => true do |t|
      t.column :name,       :string 
      t.column :description, :text
      t.column :deleted_at, :datetime
     
    end
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "millennium_goals")
    end
  end

  def self.down
    drop_table :millennium_goals
  end
  
end