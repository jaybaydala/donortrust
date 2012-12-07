class SupportMailer < ActionMailer::Base
  def subscription_result(subscription, response, order=nil)
    recipients  "tim@tag.ca"
    from        "info@uend.org"
    sent_on     Time.now
    subject     "[UEnd] Complete Subscription Response - #{response.success? ? 'Succeeded' : 'Failed'}"
    @subscription = subscription
    @response = response
    @order = order
    attachment :filename => 'response_body.html', :content_type => 'text/html', :body => @subscription.send(:gateway).response_body
  end
end
