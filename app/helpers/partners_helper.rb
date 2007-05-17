module PartnersHelper
  def partner_histories_column(record)
    link_to "Show history", {:controller => 'partner_histories', :action => 'list', :partner_id => record.id}
  end
end
