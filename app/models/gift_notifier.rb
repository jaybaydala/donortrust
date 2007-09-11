class GiftNotifier < ActionMailer::Base

  def gift(gift)
    setup_email(gift)
    @subject    = 'You have received a ChristmasFuture Gift from ' + ( gift.name != nil ? gift.name : gift.email )
    @headers    = { "Reply-To" => gift.email}
    @body[:url]  = url_for(:host => "www.christmasfuture.org", :controller => "dt/gifts", :action => "open")
  end

  def open(gift)
    setup_email(gift)
    @recipients  = "#{gift.email}"
    @subject    = "Your gift to #{gift.to_name} has been opened!"
    @headers    = {}
  end

  def remind(gift)
    setup_email(gift)
    @subject    = 'GiftNotifier#gift'
    @headers    = {}
  end

  protected
  def setup_email(gift)
    @recipients  = "#{gift.to_email}"
    @from        = "info@christmasfuture.org"
    @sent_on     = Time.now
    @body[:gift] = gift
  end
end
