class GroupNewsRel001 < ActiveRecord::Migration
  def self.up
    create_table :group_news do |t|
      t.column :group_id,             :int
      t.column :user_id,              :int
      t.column :message,              :text
      t.column :created_at,           :datetime
      t.column :updated_at,           :datetime
    end
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "group_news") if File.exists? "#{directory}/group_news.yml"
    end
  end

  def self.down
    drop_table :group_news
  end
end
