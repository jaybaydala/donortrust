class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.column :user_id,     :integer
      t.column :group_id,    :integer
      t.column :to_name,     :string
      t.column :to_email,    :string
      t.column :message,     :text
      t.column :accepted,    :boolean,   :null => true
      t.column :sent_at,     :datetime
      t.column :ip,          :string
      t.column :created_at,  :datetime
      t.column :updated_at,  :datetime
    end
  end

  def self.down
    drop_table :invitations
  end
end
