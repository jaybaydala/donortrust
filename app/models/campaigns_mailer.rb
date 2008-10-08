class CampaignsMailer < ActionMailer::Base
  HTTP_HOST = (['staging', 'production'].include?(ENV['RAILS_ENV']) ? 'www.christmasfuture.org' : 'localhost:3000') if !const_defined?('HTTP_HOST')
  def campaign_approved(campaign)
    setup
    recipients campaign.creator.full_email_address
    subject "ChristmasFuture: Campaign approved"
    body :campaign => campaign, :host => HTTP_HOST
  end
  def campaign_declined(campaign)
    setup
    recipients campaign.creator.full_email_address
    subject "ChristmasFuture: Campaign declined"
    body :campaign => campaign, :host => HTTP_HOST
  end

  def team_approved(campaign, team)
    setup
    recipients team.leader.full_email_address
    subject "ChristmasFuture: Team approved"
    body :campaign => campaign, :team => team, :host => HTTP_HOST
  end
  def team_declined(campaign, team)
    setup
    recipients team.leader.full_email_address
    subject "ChristmasFuture: Team declined"
    body :campaign => campaign, :team => team, :host => HTTP_HOST
  end
  
  def participant_approved(campaign, team, participant)
    setup
    recipients team.leader.full_email_address
    subject "ChristmasFuture: Participation approved"
    body :campaign => campaign, :team => team, :participant => participant, :host => HTTP_HOST
  end
  def participant_declined(campaign, team, participant)
    setup
    recipients team.leader.full_email_address
    subject "ChristmasFuture: Participation declined"
    body :campaign => campaign, :team => team, :participant => participant, :host => HTTP_HOST
  end

  protected
  def setup
    from "The ChristmasFuture Team <info@christmasfuture.org>"
    sent_on Time.now
  end
end

# Mailer methods have the following configuration methods available.
# 
#     * recipients - Takes one or more email addresses. These addresses are where your email will be delivered to. Sets the To: header.
#     * subject - The subject of your email. Sets the Subject: header.
#     * from - Who the email you are sending is from. Sets the From: header.
#     * cc - Takes one or more email addresses. These addresses will receive a carbon copy of your email. Sets the Cc: header.
#     * bcc - Takes one or more email addresses. These addresses will receive a blind carbon copy of your email. Sets the Bcc: header.
#     * reply_to - Takes one or more email addresses. These addresses will be listed as the default recipients when replying to your email. Sets the Reply-To: header.
#     * sent_on - The date on which the message was sent. If not set, the header wil be set by the delivery agent.
#     * content_type - Specify the content type of the message. Defaults to text/plain.
#     * headers - Specify additional headers to be set for the message, e.g. headers ‘X-Mail-Count’ => 107370.
