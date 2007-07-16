class MembershipsRel001 < ActiveRecord::Migration
  def self.up
    create_table :memberships, :id => false do |t|
      t.column :user_id,       :int
      t.column :group_id,      :int
      t.column :created_at,    :datetime
      t.column :updated_at,    :datetime
    end
    # add some indexes
    add_index :memberships, [:user_id, :group_id] 
    add_index :memberships, :group_id 

    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "memberships") if File.exists? "#{directory}/memberships.yml"
    end
  end

  def self.down
    drop_table :memberships
  end
end
