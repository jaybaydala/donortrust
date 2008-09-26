module Dt::CampaignsHelper


  def campaign_date(date)
    date.strftime("%B&nbsp;%d,&nbsp;%Y, %I:%M&nbsp;%p")
  end

end
