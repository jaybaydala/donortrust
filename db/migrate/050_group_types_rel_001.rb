class GroupTypesRel001 < ActiveRecord::Migration
  def self.up
    create_table :group_types do |t|
      t.column :name,             :string
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
    end    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "group_types") if File.exists? "#{directory}/group_types.yml"
    end
  end

  def self.down
    drop_table :group_types
  end
end
