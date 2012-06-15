class Feedback < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name, :email, :subject, :message
  validates_format_of :email, :with => /^([^@,\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "isn't a valid email address"

  after_create :send_email

  private
    def send_email
      FeedbackMailer.deliver_feedback(name, email, subject, message, created_at)
    end
end
