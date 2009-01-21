# Bug #23536: Remove the pending project associated with project id 10 (the ChristmasFuture project). This is full of blank lines and is causing performance problems whenever you try to edit project 10 in the bus_admin site
class AlterTroublesomePendingProject < ActiveRecord::Migration
  def self.up

#    begin
#      pending_project_to_delete = PendingProject.find_by_project_id(10)
#    rescue ActiveRecord::RecordNotFound
#      #swallow - just means there was no old pending record
#    end
#
#    pending_project_to_delete.destroy if pending_project_to_delete

    execute "UPDATE pending_projects SET project_xml = '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<project>\n  <actual-end-date type=\"date\" nil=\"true\"></actual-end-date>\n  <actual-start-date type=\"date\" nil=\"true\"></actual-start-date>\n  <blog-url>http://www.christmasfuture.org/blog/</blog-url>\n  <contact-id type=\"integer\">1</contact-id>\n  <continent-id type=\"integer\">180185</continent-id>\n  <country-id type=\"integer\">17</country-id>\n  <created-at type=\"datetime\">2007-10-30T17:01:51-06:00</created-at>\n  <deleted-at type=\"datetime\" nil=\"true\"></deleted-at>\n  <description>&lt;p&gt;ChristmasFuture is passionate about improving life for the poorest of the poor by inspiring and empowering North Americans to refocus a portion of their combined $1,000 billion in Christmas spending towards strategic and sustainable projects in the developing world.&lt;/p&gt;</description>\n  <dollars-spent type=\"decimal\">0.0</dollars-spent>\n  <expected-completion-date type=\"date\" nil=\"true\"></expected-completion-date>\n  <featured type=\"boolean\">false</featured>\n  <frequency-type-id type=\"integer\" nil=\"true\"></frequency-type-id>\n  <id type=\"integer\">10</id>\n  <intended-outcome>&lt;p&gt;&#160;&lt;/p&gt;\n&lt;p&gt;By offering people a meaningful and trustworthy way to refocus holiday spending, we will trigger an avalanche of giving. People of all ages, families, schools, and community groups alike will unite to literally change the world by choosing to give differently each year&#226;&#8364;&#8220;providing hope and relief to millions around the world. We are creating a legacy of change that will, in turn, renew North American&#8217;s experience of giving &#226;&#8364;&#8220; and receiving &#226;&#8364;&#8220; during the holiday celebrations.</intended-outcome>\n  <is-subagreement-signed type=\"boolean\">true</is-subagreement-signed>\n  <lives-affected type=\"integer\" nil=\"true\"></lives-affected>\n  <meas-eval-plan></meas-eval-plan>\n  <name>ChristmasFuture: Build the Organization</name>\n  <note></note>\n  <other-projects nil=\"true\"></other-projects>\n  <partner-id type=\"integer\">4</partner-id>\n  <place-id type=\"integer\">16180</place-id>\n  <program-id type=\"integer\">1</program-id>\n  <project-in-community></project-in-community>\n  <project-status-id type=\"integer\">2</project-status-id>\n  <public type=\"boolean\">true</public>\n  <rss-url>http://feeds.feedburner.com/christmasfuture</rss-url>\n  <short-description>Everyday people can change the world. Since 100% of donor dollars go towards the projects donors choose, we raise our operating funds separately. This is where you can choose to build the machine that helps everyday people change the world! </short-description>\n  <slug>admin</slug>\n  <target-end-date type=\"date\">2008-12-31</target-end-date>\n  <target-start-date type=\"date\">2008-01-01</target-start-date>\n  <total-cost type=\"decimal\">350000.0</total-cost>\n  <updated-at type=\"datetime\">2008-12-16T10:29:23-07:00</updated-at>\n  <version type=\"integer\">37</version>\n</project>\n' WHERE project_id = 10;"

  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the altered pending project data"
  end
end
