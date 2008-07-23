class CreatePartnerLimits < ActiveRecord::Migration
  def self.up
    create_table :partner_limits do |t|
      t.references :campaign
      t.references :partner

      t.timestamps
    end
  end

  def self.down
    drop_table :partner_limits
  end
end
