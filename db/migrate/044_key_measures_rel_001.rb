class KeyMeasuresRel001 < ActiveRecord::Migration
  def self.up
    create_table "key_measures", :force => true do |t|
      t.column :project_id,              :int,  :null => false
      t.column :measure_id,       :int,  :null => false
      t.column :units,              :string,  :null => false
       t.column :target,              :string,  :null => false
       t.column :millennium_goal_id,   :int
    end
 
 # if (ENV['RAILS_ENV'] == 'development')
 #     directory = File.join(File.dirname(__FILE__), "dev_data")
 #     Fixtures.create_fixtures(directory, "key_measures")
#    end
  end

  def self.down
    drop_table "key_measures"
  end
end