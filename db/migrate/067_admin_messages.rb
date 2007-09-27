class AdminMessages < ActiveRecord::Migration
  def self.up
    create_table :admin_messages do |t|
      t.column :group_id,             :int
      t.column :message,              :text
      t.column :created_at,           :datetime
      t.column :updated_at,           :datetime
    end
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "admin_messages") if File.exists? "#{directory}/admin_messages.yml"
    end
  end

  def self.down
    drop_table :admin_messages
  end
end
