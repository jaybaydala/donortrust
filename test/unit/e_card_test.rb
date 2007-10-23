require File.dirname(__FILE__) + '/../test_helper'

context "e-card tests " do
  fixtures :e_cards
   
  specify "should create e-card" do
    ECard.should.differ(:count).by(1) {create_e_card} 
  end
     
  specify "should require name" do
    lambda {
      t = create_e_card(:name => nil)
      t.errors.on(:name).should.not.be.nil
    }.should.not.change(ECard, :count)
  end
   
#    specify "should require credit" do
#      lambda {
#        t = create_e_card(:credit => nil)
#        t.errors.on(:credit).should.not.be.nil
#      }.should.not.change(ECard, :count)
#    end
   
  def create_e_card(options = {})
    ECard.create({ :name => 'Test Name', :credit => 'test', :small => uploaded_file(file_path("test.jpg"), "image/jpeg", "test") }.merge(options))
  end    
  
  def file_path(filename)
    File.expand_path("#{File.dirname(__FILE__)}/image/#{filename}")
  end
end
