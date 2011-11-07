require 'email_spec'
require 'email_spec/cucumber'

module UserHelpers
  def current_user
    return @current_user if defined?(@current_user)
  end

  def full_name() "testing" end
  def email() "testing@example.com" end
  def last_email_address() "info@uend.org" end
end
World(UserHelpers)

Then /^an email should be sent to info@uend.org$/ do

end

Then /^the email should have the feedback name "([^"]*)", email "([^"]*)", subject "([^"]*)", message "([^"]*)"/ do |name, email, subject, message|
end

Given /^the "([^"]*)" field should contain the current user's name$/ do |field|
  Given "the \"#{field}\" field should contain \"#{@user.full_name}\""
end

Given /^the "([^"]*)" field should contain the current user's email$/ do |field|
  Given "the \"#{field}\" field should contain \"#{@user.email}\""
end

Then /^a feedback record should be created with name "([^"]*)", email "$/ do |arg1|
    pending # express the regexp above with the code you wish you had
end

=begin
Then /^a feedback record should be created with name "([^"]*)", email "([^"]*)", subject "([^"]*)", message "([^"]*)" and resolved "([^"]*)"/ do |name, email, subject, message, resolved|
  f = Feedback.last
  f.name.should == name
  f.email.should == email
  f.subject.should == subject
  f.message.should == message
  f.resolved.should == (resolved == "false" ? false : true)
end
=end

Then /^the last feedback record should have "([^"]*)" value "([^"]*)"$/ do |attr, value|
  f = Feedback.last
  f.send(attr).should == value
end
