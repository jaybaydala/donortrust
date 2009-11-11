class CreateUpoweredEmailSubscribes < ActiveRecord::Migration
  def self.up
    create_table :upowered_email_subscribes do |t|
      t.string :email
      t.integer :user_id
      t.string :code
      t.timestamps
    end
  end

  def self.down
    drop_table :upowered_email_subscribes
  end
end
