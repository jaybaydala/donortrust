# GIVENS
# ================================

Given /I am on the new gift page/ do
  visits "/dt/gifts/new"
end

Given /I am on the new deposit page/ do
  visits "/dt/accounts/1/deposits/new"
end

Given /I am on the new project investment page/ do
  @project = create_project
  get("/dt/investments/new", {:project_id => @project.id})
end

Given /the Cart holds an Existing Gift of \$(\d+\.?\d{0,2})/ do |n|
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

Given /that I am logged in/ do
  login
end

# WHENS
# ================================

When /I choose the project/ do
  chooses("investment_project_id_#{@project.id}")
end

# THENS
# ================================

Then /the Gift should appear in the Cart/ do
  response.should have_tag("#cart td div.gift")
end
Then /the Investment should appear in the Cart/ do
  response.should have_tag("#cart td div.investment")
end
Then /the Deposit should appear in the Cart/ do
  response.should have_tag("#cart td div.deposit")
end

Then /there should be a link to Preview the Gift/ do
  response.should have_tag("#cart td div.gift input[type=button][value=Preview]")
end

Then /there should be a link to Edit the Gift/ do
  response.should have_tag("#cart td a[href=/dt/gifts/0/edit]")
end
Then /there should be a link to Edit the Investment/ do
  response.should have_tag("#cart td a[href=/dt/investments/0/edit]")
end
Then /there should be a link to Edit the Deposit/ do
  response.should have_tag("#cart td a[href=/dt/accounts/#{@user.id}/deposits/0/edit]")
end

Then /there should be a link to Remove the (\w+)/ do
  response.should have_tag("#cart td a[href=/dt/cart?id=0][onclick~=m.setAttribute('name', '_method'); m.setAttribute('value', 'delete');]", :count => 1) do |t|
    t.should have_tag("img[alt=Remove item from cart]")
  end
end

Then /the Cart Total should be \$(\d+\.?[\d]{0,2})/ do |n|
  response.should have_tag("#cart tr.footer td:last-child", "#{number_to_currency(n)}")
end

# HELPERS
# ================================

def add_gift(amount)
  @cart = Cart.new
  response.session[:cart] = @cart
  gift = create_gift({:amount => amount})
  @cart.add_item(gift)
end
