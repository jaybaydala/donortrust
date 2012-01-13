require File.dirname(__FILE__) + '/../../spec_helper'

describe Iend::UsersController do
  it "should use DtApplicationController" do
    controller.should be_kind_of(DtApplicationController)
  end
  
  let(:project) { mock_model(Project, :name => "foo", :fundable? => true, :lives_affected => 20).as_null_object }
  let(:gift) { mock_model(Gift, :project => project, :valid => true).as_null_object }
  let(:cart) { mock_model(Cart, :subscription? => false).as_null_object }
  let(:cart_line_item) { mock_model(CartLineItem, :item => gift) }
  let(:user) { mock_model(User, :gifts => [ gift ]).as_null_object }

  context "when logged_in?" do
    before do
      controller.stub(:logged_in?).and_return(true)
      controller.stub(:current_user).and_return(user)
      user.stub(:in_country?).and_return(true)
    end

    it "should render show" do
      Project.stub(:current).and_return(mock(:all => [ project ]))
      user.should_receive(:gifts)
      get 'show', :id => 'current'
    end
  end
end
