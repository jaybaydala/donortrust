class BusAdmin::BudgetItemsController < ApplicationController
  
  before_filter :login_required

  def index
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @budget_item = BudgetItem.new
    @budget_item.project_id = params[:project_id]
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @budget_item = BudgetItem.new(params[:budget_item])
    @budget_item.project_id = params[:project_id]
    @success = @budget_item.save
    if @success
      flash[:notice] = "Successfully saved the budget item."
      respond_to do |format|
        format.html {redirect_to(bus_admin_project_budget_items_url(@budget_item.project_id))}
      end
    else
      flash[:error] = "An error occurred while attempting to save the budget item."
      respond_to do |format|
        format.html {redirect_to(bus_admin_project_new_budget_item_url(@budget_item.project_id))}
      end
    end
  end
  
  def edit
    begin
      @budget_item = BudgetItem.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end
  
  def update
    begin
      @budget_item = BudgetItem.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @success = @budget_item.update_attributes(params[:budget_item])
    if @success
      flash[:notice] = "Successfully updated the budget item."
      respond_to do |format|
        format.html {redirect_to(bus_admin_project_budget_items_url(@budget_item.project_id))}
      end
    else
      flash[:error] = "An error occurred while attempting to update the budget item."
      respond_to do |format|
        format.html {redirect_to(bus_admin_project_edit_budget_item_url(@budget_item.project_id, @budget_item))}
      end
    end
  end
  
  def destroy
    begin
      @budget_item = BudgetItem.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @success = @budget_item.destroy
    if @success
      flash[:notice] = "Successfully deleted the budget item."
    else
      flash[:error] = "An error occurred while attempting to delete the budget item"
    end
    respond_to do |format|
      format.html {redirect_to(bus_admin_project_budget_items_url(@budget_item.project_id))}
    end
  end
end
