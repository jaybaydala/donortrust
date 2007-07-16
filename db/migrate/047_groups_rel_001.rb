class GroupsRel001 < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.column :name,             :string
      t.column :description,      :text
      t.column :group_type_id,    :int
      t.column :public,           :boolean
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
    end    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "groups") if File.exists? "#{directory}/groups.yml"
    end
  end

  def self.down
    drop_table :groups
  end
end
