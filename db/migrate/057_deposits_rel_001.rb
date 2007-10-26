class DepositsRel001 < ActiveRecord::Migration
  def self.up
    create_table :deposits do |t|
      t.column :amount,               :decimal, :precision => 12, :scale => 2
      t.column :first_name,           :string
      t.column :last_name,            :string
      t.column :address,              :string
      t.column :city,                 :string
      t.column :province,             :string
      t.column :postal_code,          :string
      t.column :country,              :string
      t.column :credit_card,          :string, :limit => 4
      t.column :card_expiry,          :date
      t.column :authorization_result, :string
      t.column :gift_id,              :int
      t.column :user_id,              :int
      t.column :created_at,           :datetime
      t.column :updated_at,           :datetime
    end
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "deposits") if File.exists? "#{directory}/deposits.yml"
    end
  end

  def self.down
    drop_table :deposits
  end
end
