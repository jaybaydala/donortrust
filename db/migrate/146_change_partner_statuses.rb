class ChangePartnerStatuses < ActiveRecord::Migration
  def self.up
    directory = File.join(File.dirname(__FILE__), "dev_data")
    Fixtures.create_fixtures(directory, "partner_statuses") if File.exists? "#{directory}/partner_statuses.yml"
  end

  def self.down
  end
end
