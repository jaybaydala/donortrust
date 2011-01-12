class BusAdmin::CampaignsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization

  active_scaffold do |config|
    config.list.columns = [:name, :event_date, :funds_raised, :funds_allocated]
    config.actions = [:create, :list, :search, :show ]
    config.action_links.add(:close, { :label => "Close", :method => :put, :crud_type => :update, :type => :record, :inline => false, :confirm => "Are you sure you want to close the campaign? This will auto-allocate any funds currently given to the campaign." })
  end

  def close
    # stop accepting pledges/donations on that campaign, and put/deposit the funds from that campaign onto the projects that were selected for that campaign
    # --- if no projects were selected for a campaign, the funds will automatically be deposited into the 'CF Allocations" user account with a note that it came from a particular campaign
    # --- if the projects are totally funded from a campaign and there is excess cash it too will be deposited in the CF allocations account
    # - The UEnd / DonorTrust super-users have the ability to put these funds in the CF Allocations User account against projects by simply going thru the normal checkout process for making a donation to a project...and on the screen that they tell how to pay (from their credit card, account, etc) they have an additional option, to pay from the Allocations account. THey must put in a note to tell why this money is being put on this project (e.g. this is from the OneYoga campaign etc)
    @campaign = Campaign.find(params[:id])
    @order = @campaign.close!
    if @order
      flash[:notice] = "The campaign has been closed successfully! All funds have been allocated.<br />\n"
      flash[:notice] += @order.notes.gsub(/\n/,"<br />\n")
    else
      flash[:notice] = "The campaign could not be closed"
    end
    redirect_to :action => "index"
    # render :text => @campaign.inspect
  end
end
