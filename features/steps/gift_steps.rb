Given /I have received a project gift/ do
  @project = Project.generate!
  @gift = Gift.generate!(:project => @project)
end

Given /^the Cart holds an Existing Gift of \$(\d+\.?\d{0,2})$/ do |n|
  to_email = "to@example.com"
  from_email = "from@example.com"
  post("/dt/gifts", {:gift => {
      :amount                => n,
      :name                  => "From Me",
      :email                 => from_email,
      :email_confirmation    => from_email,
      :to_name               => "To You",
      :to_email              => to_email,
      :to_email_confirmation => to_email,
      :message               => "This is a message",
      :send_email            => true,
      :send_at               => 2.hours.from_now
    }})
end

Given /^I am on the new gift page$/ do
  visits "/dt/gifts/new"
end

Given /^my cart has (\d+) \$(\d+\.?\d*) gifts in it$/ do |number, amount|
  number.to_i.times do |n|
    add_gift_to_cart(amount)
  end
end

Given /^I add a gift for \$([\d]+[\.]?[\d]?) to my cart$/ do |amount|
  add_gift_to_cart(amount)
end

Given /^I have received a gift for \$([\d]+[\.]?[\d]?)$/ do |amount|
  @gift = Gift.generate!(:amount => amount)
end

When /^I open the gift$/ do
  open_gift(@gift.pickup_code)
end

When /^I add (\d+) gifts to the cart$/ do |num|
  (1..num.to_i).each{|i| add_gift_to_cart(i)}
end

Then /I should see what I have been given/ do
  response.should have_tag("div.notice", "You have been given #{number_to_currency(@gift.amount)}!")
end
Then /I should see a link to the Project/ do
  response.should have_tag("a[href=/dt/projects/#{@project.id}]", "#{@project.name}")
end

