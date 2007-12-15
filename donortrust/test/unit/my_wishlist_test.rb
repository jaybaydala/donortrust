require File.dirname(__FILE__) + '/../test_helper'


context "My Wish List Tests " do
  fixtures :my_wishlists, :projects, :users
 
  specify "should create a wish list" do
    MyWishlist.should.differ(:count).by(1) {create_wish_list} 
  end

  specify "project id should be unique" do
    lambda {
      t = create_wish_list(:project_id => 1)
      t.errors.on(:project_id).should.be.nil
      t = create_wish_list(:project_id => 1)
      t.errors.on(:project_id).should.not.be.nil
    }.should.change(MyWishlist, :count)
  end
   
  specify "should require project" do
    lambda {
      t = create_wish_list(:project_id => nil)
      t.errors.on(:project_id).should.not.be.nil
    }.should.not.change(MyWishlist, :count)
  end
 
  specify "should require user id" do
    lambda {
      t = create_wish_list(:user_id => nil)
      t.errors.on(:user_id).should.not.be.nil
    }.should.not.change(MyWishlist, :count)
  end
 
  def create_wish_list(options = {})
    MyWishlist.create({ :user_id => 1, :project_id => 1 }.merge(options))
  end                                                          
end
