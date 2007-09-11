require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/gift_test_helper'

# see user_transaction_test.rb for amount and user tests
context "Gift Observer" do
  include DtAuthenticatedTestHelper
  include GiftTestHelper
  fixtures :user_transactions, :gifts, :users

  setup do
  end
  
  specify "I'm not sure what I can test here" do
    true.should.be true
  end
  xspecify "should create a gift" do
    g = create_gift 
  end
end
