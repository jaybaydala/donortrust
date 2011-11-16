class Feedback < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name, :email, :subject, :message

  after_create :send_email

  private

  def send_email
    FeedbackMailer.deliver_feedback(name, email, subject, message, created_at)
  end
end
