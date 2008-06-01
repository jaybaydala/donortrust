class GiftsRel001 < ActiveRecord::Migration
  def self.up
      create_table :gifts do |t|
        t.column :amount,               :decimal, :precision => 12, :scale => 2
        t.column :name,                 :string
        t.column :email,                :string
        t.column :to_name,              :string
        t.column :to_email,             :string
        t.column :message,              :text
        t.column :first_name,           :string
        t.column :last_name,            :string
        t.column :address,              :string
        t.column :city,                 :string
        t.column :province,             :string
        t.column :postal_code,          :string
        t.column :country,              :string
        t.column :credit_card,          :string, :limit => 4
        t.column :card_expiry,          :date
        t.column :project_id,           :int
        t.column :authorization_result, :string
        t.column :pickup_code,          :string, :limit => 40
        t.column :picked_up_at,         :datetime
        t.column :ecard,                :string
        t.column :send_at,              :datetime
        t.column :sent_at,              :datetime
        t.column :user_id,              :int
        t.column :created_at,           :datetime
        t.column :updated_at,           :datetime
      end
      if (ENV['RAILS_ENV'] == 'development')
        directory = File.join(File.dirname(__FILE__), "dev_data")
        Fixtures.create_fixtures(directory, "gifts") if File.exists? "#{directory}/gifts.yml"
      end
    end

    def self.down
      drop_table :gifts
    end
end
