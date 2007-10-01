class CreateTaxReceipts < ActiveRecord::Migration
  def self.up
    create_table "tax_receipts", :force => true do |t|
      t.column :first_name,                :string
      t.column :last_name,                 :string
      t.column :address,                   :string
      t.column :city,                      :string
      t.column :province,                  :string
      t.column :postal_code,               :string
      t.column :country,                   :string
      t.column :user_id,                   :int
      t.column :investment_id,             :int
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "tax_receipts") if File.exists? "#{directory}/tax_receipts.yml"
    end
  end

  def self.down
    drop_table :tax_receipts
  end
end

