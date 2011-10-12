require File.dirname(__FILE__) + '/../spec_helper'

describe Project do
  before do
    Factory(:project_status_active)
    Factory(:project_status_completed)
  end

  let(:project) { Factory(:project) }
  subject { project }

  context "associations" do
    it { should belong_to(:project_status) }
    it { should belong_to(:program) }
    it { should belong_to(:partner) }
    it { should belong_to(:place) }
    it { should belong_to(:contact) }
    it { should belong_to(:frequency_type) }
    it { should have_many(:milestones) }
    it { should have_many(:tasks) }
    it { should have_many(:project_you_tube_videos) }
    it { should have_many(:project_flickr_images) }
    it { should have_many(:financial_sources) }
    it { should have_many(:budget_items) }
    it { should have_many(:collaborating_agencies) }
    it { should have_many(:ranks) }
    it { should have_many(:investments) }
    it { should have_many(:key_measures) }
    it { should have_many(:my_wishlists) }
    it { should have_many(:users) }
    it { should have_and_belong_to_many(:groups) }
    it { should have_and_belong_to_many(:sectors) }
    it { should have_and_belong_to_many(:causes) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
  end
  
  describe "project places" do
    before do
      # set up a community and nation for the project
      community_place_type = PlaceType.community || Factory(:place_type, :name => "City")
      country_place_type = PlaceType.country || Factory(:place_type, :name => "Country")
      country = Factory(:place, :place_type_id => country_place_type.id)
      @community = project .place
      @community.update_attributes(:place_type => community_place_type, :parent => country)
      project.update_attributes(:country => country);
    end
    it "should have a community available to it" do
      project.community_id.should_not be_nil
      project.community_id?.should be_true
      project.community.should_not be_nil
    end
    it "should have a nation available to it" do
      project.nation_id.should_not be_nil
      project.nation_id?.should be_true
      project.nation.should_not be_nil
    end
  end
  
  describe "financials" do
    before do
      project.update_attributes(:total_cost => 15000, :dollars_spent => 4000)
      project.stub(:dollars_raised).and_return(10000.25) # 4999.75 is current_need
    end
    
    it "should return total_need" do
      project.total_cost.should == 15000
    end
    it "should return dollars_spent" do
      project.dollars_spent.should == 4000
    end
    it "should return dollars_raised" do
      project.dollars_raised.should == 10000.25
    end
    it "should return current_need as total_need - dollars_raised" do
      project.current_need.should == project.total_cost - project.dollars_raised
    end
  end
  
  describe "fundable? method" do
    before do
      @project_status_marketing = Factory(:project_status, :name => "In Marketing")
      @project_status_active = ProjectStatus.active || Factory(:project_status_active)
      @project_status_completed = ProjectStatus.completed || Factory(:project_status_completed)
      project.stub(:current_need).and_return(1)
    end
    it "should be fundable if ProjectStatus is active" do
      project.update_attributes(:project_status => @project_status_active)
      project.fundable?.should be_true
    end
    it "should not be fundable if ProjectStatus is not active" do
      project.update_attributes(:project_status => @project_status_completed)
      project.fundable?.should be_false
      project.update_attributes(:project_status => @project_status_marketing)
      project.fundable?.should be_false
    end
  end
  
  describe "find_public method" do
    before do
      project.stub(:current_need).with(1)
      @project_status_marketing = Factory(:project_status, :name => "In Marketing")
      @project_status_active = ProjectStatus.active || Factory(:project_status, :name => "Active")
      @project_status_completed = ProjectStatus.completed || Factory(:project_status, :name => "Completed")
      @started_project = Factory(:project)
      @completed_project = Factory(:project)
      @started_project.update_attributes(:project_status => @project_status_active)
      @completed_project.update_attributes(:project_status => @project_status_completed)
      project.update_attributes(:project_status => @project_status_marketing)
    end
    it "should include \"started\" projects" do
      Project.find_public(:all).include?(@started_project).should be_true
    end
    it "should include \"completed\" projects" do
      Project.find_public(:all).include?(@completed_project).should be_true
    end
    it "should not include \"in marketing\" projects" do
      Project.find_public(:all).include?(project).should be_false
    end
  end
  
  describe "dollars_raised method" do
    it "should add up the investments" do
      project.stub(:current_need).and_return(5000)
      project.investments = [Investment.new(:amount => 10), Investment.new(:amount => 25), Investment.new(:amount => 15)]
      project.dollars_raised.should == 50
    end
  end
  describe "summarized_description" do
    before do
      project.update_attributes(:description => "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam nibh arcu, commodo nec, mattis vitae, pulvinar quis, elit. Nunc lorem. Sed vitae est ut felis pharetra volutpat. Aenean lacinia ligula id orci ultrices scelerisque. Donec ullamcorper, massa vel luctus eleifend, nibh dolor blandit leo, eu vulputate odio nisl at ipsum. Mauris tempor nunc. Proin sodales rutrum elit. Aliquam rutrum laoreet odio. Aliquam erat volutpat. Mauris tempus dolor sit amet est. In sit amet turpis sed ligula lobortis tristique. Nullam non eros. Aliquam erat volutpat. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Sed vel sapien. Pellentesque in pede. Sed posuere nunc blandit dui. Vestibulum rutrum fringilla est. Nullam in pede quis mauris lacinia laoreet. Donec dolor. Duis sed diam. Nunc cursus imperdiet ipsum. Aliquam rutrum lacus quis felis. Proin commodo gravida enim. Praesent varius iaculis eros. Sed tellus pede, aliquam vel, ultricies eget, malesuada feugiat, arcu. Cras tristique cursus magna. Aliquam lobortis diam quis elit. Vestibulum enim leo, sollicitudin eget, consequat id, accumsan nec, sapien. Nullam leo nisi, vestibulum a, sollicitudin id, convallis vitae, augue. Vestibulum venenatis pede eget magna. Sed tortor lorem, consectetuer sed, commodo vitae, molestie sit amet, libero. Donec ullamcorper tincidunt neque. Nulla in metus. Pellentesque a lorem. Ut tellus neque, dignissim vitae, rutrum ut, pharetra non, arcu. Fusce nulla. Sed eget justo in metus rutrum malesuada. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Proin non justo ac tellus elementum elementum. Ut ac velit. Sed ligula magna, vulputate sed, sagittis dignissim, mattis non, nisl. Mauris vestibulum arcu ac tellus. Maecenas interdum tellus.")
    end
    it "should return a 50 word description by default" do
      project.summarized_description.split.size.should == 50
    end
    it "should return the number of words requested" do
      project.summarized_description(25).split.size.should == 25
    end
    it "should return no more than the number of words in the description" do
      project.summarized_description(project.description.split.size + 20).split.size.should == project.description.split.size
    end
    it "should not end in \"...\" if requesting longer than the description length" do
      project.summarized_description(project.description.split.size + 1)[-3,3].should_not == "..."
    end
    it "should end in \"...\" if requesting shorter than the description length" do
      project.summarized_description(project.description.split.size - 1)[-3,3].should == "..."
    end
  end

  describe "community_project_count" do
    before do
      @place = project.place
      @place_type = Factory(:place_type, :name => "City")
      @place.update_attributes(:place_type => @place_type)
      project.update_attributes(:place => @place)
      @another_project = Factory(:project)
      @another_project.update_attributes(:place => @place)
    end
    it "should return the number os projects in the community as an integer" do
      project.community_project_count.should == 2
    end
  end
  
  describe "public_groups" do
    before do
      @group_type = GroupType.create(:name => "Test Group")
      @groups = [
        Group.new(:name => "group1", :private => false, :group_type => @group_type), 
        Group.new(:name => "group2", :private => false, :group_type => @group_type), 
        Group.new(:name => "group3", :private => true, :group_type => @group_type)
        ]
      project.groups = @groups
    end
    it "should return all the associated public_groups" do
      project.public_groups.size.should == 2
    end
  end
end
