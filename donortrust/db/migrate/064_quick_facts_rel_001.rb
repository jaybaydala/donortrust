class QuickFactsRel001 < ActiveRecord::Migration
def self.up
     create_table :quick_facts do |t|
        t.column :name,               :string
        t.column :description,        :string
        t.column :quick_fact_type_id, :int, :null => false
      end
      if (ENV['RAILS_ENV'] == 'development')
        directory = File.join(File.dirname(__FILE__), "dev_data")
        Fixtures.create_fixtures(directory, "quick_facts") if File.exists? "#{directory}/quick_facts.yml"
    end
  end

  def self.down
     drop_table :quick_facts
  end
end
