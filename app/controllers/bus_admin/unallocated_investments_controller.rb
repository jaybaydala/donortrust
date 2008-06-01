class BusAdmin::UnallocatedInvestmentsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  def index
    @unallocated_investments = Investment.find(:all, :conditions => ['project_id = 11'])
   end

  def unallocate

    @investmentId = params[:investment_id]
    @investment = Investment.find(@investmentId)

    @investment.project_id = params[:projectId]
    @investment.save

    if @investment.valid?
      flash[:notice] = 'Investment was saved.'
    else
      flash[:notice] = @investment.errors.to_xml
      break
    end
    render(:update) { |page| page.call 'location.reload' }
  end
end


