class CreateShares < ActiveRecord::Migration
  def self.up
      create_table :shares do |t|
        t.column :name,                 :string
        t.column :email,                :string
        t.column :to_name,              :string
        t.column :to_email,             :string
        t.column :message,              :text
        t.column :project_id,           :integer
        t.column :e_card_id,            :integer
        t.column :send_at,              :datetime
        t.column :sent_at,              :datetime
        t.column :ip,                   :string
        t.column :user_id,              :integer
        t.column :created_at,           :datetime
        t.column :updated_at,           :datetime
      end
      if (ENV['RAILS_ENV'] == 'development')
        directory = File.join(File.dirname(__FILE__), "dev_data")
        Fixtures.create_fixtures(directory, "shares") if File.exists? "#{directory}/shares.yml"
      end
    end

    def self.down
      drop_table :shares
    end
end
