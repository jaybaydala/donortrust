class Gift < ActiveRecord::Base
  generator_for :amount => 100
  generator_for :to_email, :method => :generate_email, :start => "toemail@example.com"
  generator_for :email, :method => :generate_email, :start => "fromemail@example.com"
  
  def self.generate_email(start)
    @email ||= start
    user, domain = @email.split('@')
    @email = user.succ + '@' + domain
  end
end
