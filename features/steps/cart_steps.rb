Then /^the Gift should appear in the Cart$/ do
  response.should have_tag("#cart td div.gift")
end
Then /^the Investment should appear in the Cart$/ do
  response.should have_tag("#cart td div.investment")
end
Then /^the Deposit should appear in the Cart$/ do
  response.should have_tag("#cart td div.deposit")
end

Then /^I should see (\d+) gifts in my cart$/ do |count|
  response.should have_tag("#cart div.gift", :count => count.to_i)
end

Then /^there should be a link to Preview the Gift$/ do
  response.should have_tag("#cart td div.gift input[type=button][value=Preview]")
end

Then /^there should be a link to Edit the Gift$/ do
  response.should have_tag("#cart td div.giftcontrols a[href=/dt/gifts/0/edit]")
end
Then /^there should be a link to Edit the Investment$/ do
  response.should have_tag("#cart td div.investmentcontrols a[href=/dt/investments/0/edit]")
end
Then /^there should be a link to Edit the Deposit$/ do
  response.should have_tag("#cart td div.depositcontrols a[href=/dt/accounts/#{@user.id}/deposits/0/edit]")
end

Then /^there should be a link to Remove the (\w+)$/ do |cart_item|
  response.should have_tag("#cart td div.#{cart_item.downcase}controls a[href=/dt/cart?id=0][onclick~=m.setAttribute('name', '_method'); m.setAttribute('value', 'delete');]", :count => 1) do |t|
    t.should have_tag('img[title="Remove this item from your cart"]')
  end
end

Then /^the Cart Total should be \$(\d+\.?[\d]{0,2})$/ do |n|
  response.should have_tag("#cart tr.footer td:last-child", "#{number_to_currency(n)}")
end

Then /^I should see the cart pagination$/ do
  response.should have_tag("div.pagination a[href=/dt/cart?cart_page=2]", "2", :count => 2)
  response.should have_tag("div.pagination a[href=/dt/cart?cart_page=2]", /Next/i, :count => 2)
end
Then /^I should see (\d+) gift\(s\) on the first page of the cart$/ do |num|
  response.should have_tag("#cart div.gift", :count => num.to_i)
end
Then /^I should see (\d+) gift\(s\) on the second page of the cart$/ do |num|
  visits "/dt/cart?cart_page=2"
  response.should have_tag("#cart div.gift", :count => num.to_i)
end


Then /^I should see the checkout cart pagination$/ do
  response.should have_tag("div.pagination a[href=/dt/checkout/new?cart_page=2]", "2", :count => 2)
  response.should have_tag("div.pagination a[href=/dt/checkout/new?cart_page=2]", /Next/i, :count => 2)
end
Then /^I should see (\d+) gift\(s\) on the first page of the checkout cart$/ do |num|
  response.should have_tag("#cart div.gift", :count => num.to_i)
end
Then /^I should see (\d+) gift\(s\) on the second page of the checkout cart$/ do |num|
  visits "/dt/checkout/new?cart_page=2"
  response.should have_tag("#cart div.gift", :count => num.to_i)
end
Then /^I should see (\d+) gift\(s\) on the third page of the checkout cart$/ do |num|
  visits "/dt/checkout/new?cart_page=3"
  response.should have_tag("#cart div.gift", :count => num.to_i)
end

