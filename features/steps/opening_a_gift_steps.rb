Before do
  Project.generate!(:slug => "unallocated") unless Project.unallocated_project
  Project.generate!(:slug => "admin") unless Project.admin_project
end
Given /I have received a project gift/ do
  @project = Project.generate!
  @gift = Gift.generate!(:project => @project)
end
When /^I open the gift$/ do
  open_gift(@gift.pickup_code)
end
Then /I should see what I have been given/ do
  response.should have_tag("div.notice", "You have been given #{number_to_currency(@gift.amount)}!")
end
Then /I should see a link to the Project/ do
  response.should have_tag("a[href=/dt/projects/#{@project.id}]", "#{@project.name}")
end

Then /the gift information should be in the session/ do
  response.session[:gift_card_id].should == @gift.id
  response.session[:gift_card_balance].should == @gift.balance
end
Then /I should see an option to "find a project to donate to"/ do
  response.should have_tag("a[href=/dt/search]", "find a project to donate to")
end
Then /I should see an option to "let CF figure it out"/ do
  response.should have_tag("a[href=/dt/investments/new?]", "let ChristmasFuture figure it out")
end
Then /I should see an option to "Deposit it into my account"/ do
  response.should have_tag("a[href=/dt/accounts/false/deposits/new?deposit%5Bamount%5D=%24#{number_to_currency(@gift.amount).sub(/^\$/, "")}]", "Deposit it into my account")
end
Then /I should see an option to "Donate it to the CF Operations project" PENDING/ do
  response.should have_tag("a[href=/dt/investments/new]", "Donate it to the ChristmasFuture Operational Funds project")
end
Then /I should see an option to "Do nothing"/ do
  response.should have_tag("li", /^Do nothing/)
end


Given /I am opening a gift/ do
  @gift = Gift.generate!
  open_gift(@gift.pickup_code)
end
When /I choose any of the gift opening options/ do
  @project = Project.generate!
  visits "/dt/investments/new?project_id=#{@project.id}"
end
Then /I should see my gift card balance/ do
  response.should have_tag("div.notice", "Your Gift Card Balance is: #{number_to_currency(@gift.amount)}")
end

Then /I should see my gift card total in the top right corner/ do
  response.should have_tag("#giftcard-amount", "Gift Card Amount: #{number_to_currency(@gift.amount)}")
end

When /I go anywhere in the site/ do
  visits "/dt"
end
Then /there should be a cookie with the Gift Card Amount/ do
  request.cookies["gift_card_amount"].first.should == @gift.amount.to_s
end
Then /there should be a cookie with the Gift Card id/ do
  request.cookies["gift_card_id"].first.should == @gift.id.to_s
end