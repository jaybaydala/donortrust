module Dt::CampaignsHelper


  def campaign_date(date)
    date.strftime("%B&nbsp;%d,&nbsp;%Y")
  end

  def campaign_time(date)
    date.strftime("%I:%M&nbsp;%p")
  end

end
