class BusAdmin::StatsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'

  include BusAdmin::ProjectsHelper
  include BusAdmin::ProgramsHelper
  
  def index
    @noOfDeposits = Deposit.find(:all).size
    @totalDeposits = Deposit.dollars_deposited
    @noOfGiftsGiven = Gift.find(:all).size
    @totalGiftsGiven = Gift.dollars_gifted
    @noOfGiftsRedeemed = Gift.find(:all, :conditions => ["pickup_code is null"] ).size
    @totalGiftsRedeemed = Gift.dollars_redeemed
    @projects = Project.find(:all, :conditions => ['projects.project_status_id in (?) AND projects.id != ?', [2,4], Project.cf_admin_project.id])
    @noOfProjects = @projects.size
    @noOfDonors = User.find(:all).size
    @noOfGroups = Group.find(:all).size
    @noOfPeopleGroups = Membership.count(:all,  :select => "DISTINCT user_id")
    @noOfTellaFriend = Share.find(:all).size
    @Partners = Partner.find(:all)
    
    @Total_needed = 0
    @projects.each do |project|
      @Total_needed = @Total_needed + project.current_need 
    end
    
    
    @totalInvestments = 0
    @noOfInvestments=0
    Investment.find(:all, :conditions => ['projects.project_status_id in (?) AND projects.id != ?', [2,4], Project.cf_admin_project.id], :include =>  :project).each do |investment|
      if investment.project.get_percent_raised < 100
         @totalInvestments =  @totalInvestments + investment.amount
         @noOfInvestments = @noOfInvestments +1
      end
    end
    
    @noOfAdminInvestments = 0
    @AdminInvestmentsFront = 0
    @AdminInvestmentsBack = 0
    Investment.find(:all, :conditions => ['projects.id = ?',  Project.cf_admin_project.id], :include =>  :project).each do |investment|
      @noOfAdminInvestments = @noOfAdminInvestments +1
      if investment.user_id == -1
        @AdminInvestmentsBack = @AdminInvestmentsBack + investment.amount
      else
        @AdminInvestmentsFront = @AdminInvestmentsFront + investment.amount
      end
    end
   
 end
  
  
  
  
end