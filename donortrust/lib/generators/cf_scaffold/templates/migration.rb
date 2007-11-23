class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= controller_file_name %> do |t|
<% for attribute in attributes -%>
      t.column :<%= attribute.name %>, :<%= attribute.type %>
<% end -%>
    end
  end

  def self.down
    drop_table :<%= controller_file_name %>
  end
end
