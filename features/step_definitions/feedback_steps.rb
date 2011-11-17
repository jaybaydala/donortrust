Given /^the "([^"]*)" field should contain the current user's name$/ do |field|
  Given "the \"#{field}\" field should contain \"#{@user.full_name}\""
end

Given /^the "([^"]*)" field should contain the current user's email$/ do |field|
  Given "the \"#{field}\" field should contain \"#{@user.email}\""
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
