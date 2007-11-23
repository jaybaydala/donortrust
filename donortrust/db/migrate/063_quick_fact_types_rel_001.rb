class QuickFactTypesRel001 < ActiveRecord::Migration
  def self.up
    create_table :quick_fact_types do |t|
        t.column :name,           :string
        t.column :description,    :string       
    end
    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "quick_fact_types") if File.exists? "#{directory}/quick_fact_types.yml"
    end
   
  end

  def self.down
     drop_table :quick_fact_types
  end
end
