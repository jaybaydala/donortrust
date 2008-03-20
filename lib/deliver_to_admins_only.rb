# ultimately, I'd like to be able to deliver messages, but only to the admins
# This allows us to test real mail sending (like from our schedulers, for instance)
module DeliverToAdminsOnly
  def self.included(base)
    base.class_eval do
      alias_method_chain :create_mail, :admins_only if ENV['RAILS_ENV'] == 'staging'
    end
  end
  
  ADMIN_EMAILS = ["tim@pivotib.com"]
  def create_mail_with_admins_only
    old_recipients = recipients
    recipients ADMIN_EMAILS # put our emails in place
    logger.info "Readjusted mail to only send to admins: #{recipients.join(', ')}" unless logger.nil?
    logger.info "This email would have been delivered here: #{old_recipients}\n\n"
    create_mail_without_admins_only
  end
end
class ActionMailer::Base
  include DeliverToAdminsOnly
end
