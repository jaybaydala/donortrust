require File.dirname(__FILE__) + '/../../test_helper'
require 'pp'

context "Project" do
  fixtures :projects, :places
  
  setup do
  end

  specify "The project should have a project name & description" do
    @project = Project.find(1)
    @project.name.should.not.be.nil
    @project.description.should.not.be.nil
  end

  specify "A project's community should be available through @project.community, etc." do
    @project = Project.find(1)
    @project.community_id
    @project.community_id?.should.be true
    @project.community.should.not.be.nil
  end

  specify "A project's nation should be available through @project.nation, etc." do
    @project = Project.find(1)
    @project.nation_id.should == 2 #uganda
    @project.nation_id?.should.be true
    @project.nation.should.not.be.nil
  end

  specify "should return community_projects_count as an int" do
    @project = Project.find(1)
    @project.community_project_count.should >= 0
  end
  
  specify "should return total_cost, dollars_spent, dollars_raised and current_need" do
    @project = Project.find(1)
    @project.total_cost.should.be > 0
    @project.dollars_spent.should.be >= 0
    @project.dollars_raised.should.be >= 0
    @project.current_need.should.equal @project.total_cost - @project.dollars_raised
  end
  
  specify "dollars_raised should equal the Investments in the project" do
    @project = Project.find(1)
    total = 0
    Investment.find(:all, :conditions => {:project_id => @project.id}).each do |investment|
      total = total + investment.amount
    end
    @project.dollars_raised.should.equal total
  end
  
  specify "public_groups should return an array of non-private groups" do
    @project = Project.find(1)
    @project.public_groups.class.should.be Array
  end
end

context "Project Statuses" do
  fixtures :projects, :partners
  
  specify "Project.find_public should only return projects that are started (2) or completed (4)" do
    @project = Project.find_public(:all).size.should.equal 2
  end

  specify "Project.find_public should return a specific id" do
    @project = Project.find_public(2).id.should.equal 2
  end

  specify "Project.find_public should return nil if it's a non-public project" do
    begin
      @project = Project.find_public(1).should.raise ActiveRecord::RecordNotFound
    rescue
    end
  end

  specify "Project.find_public should only return a specific id with a conditions hash" do
    @project = Project.find_public(:all, :conditions => {:partner_id => 1}).size.should.equal 2
    @project = Project.find_public(:first, :conditions => {:partner_id => 1}, :order => :id).id.should.equal 2
  end

  specify "Project.find_public should only return a specific id with a conditions string" do
    @project = Project.find_public(:all, :conditions => "partner_id = 1").size.should.equal 2
    @project = Project.find_public(:first, :conditions => "partner_id = 1", :order => :id).id.should.equal 2
  end

  specify "Project.find_public should only return a specific id with a conditions array" do
    @project = Project.find_public(:all, :conditions => ["partner_id = ?", 1]).size.should.equal 2
    @project = Project.find_public(:first, :conditions => ["partner_id = ?", 1], :order => :id).id.should.equal 2
  end

  specify "Project.find_public should not return a project with a deleted partner_id" do
    Partner.find(partners(:one).id).destroy
    @project = Project.find_public(:first, :conditions => ["partner_id = ?", 1], :order => :id)
    @project.should.be.nil
  end
end