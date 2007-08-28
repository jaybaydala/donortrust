class InvestmentsRel001 < ActiveRecord::Migration
  def self.up
      create_table :investments do |t|
        t.column :amount,               :decimal, :precision => 12, :scale => 2
        t.column :user_id,              :int
        t.column :project_id,           :int
        t.column :group_id,             :int
        t.column :created_at,           :datetime
        t.column :updated_at,           :datetime
      end
      if (ENV['RAILS_ENV'] == 'development')
        directory = File.join(File.dirname(__FILE__), "dev_data")
        Fixtures.create_fixtures(directory, "investments") if File.exists? "#{directory}/investments.yml"
      end
    end

    def self.down
      drop_table :investments
    end
end
