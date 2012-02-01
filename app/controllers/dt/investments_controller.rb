require 'order_helper'

class Dt::InvestmentsController < DtApplicationController
  helper 'dt/places'
  before_filter :find_cart
  include OrderHelper
  def initialize
    @page_title = "Give"
  end

  def new
    @investment = Investment.new( params[:investment] )
    @investment.project = Project.for_country(country_code).find(params[:project_id]) if params[:project_id].present?
    # load the unallocated_project if no other project is loaded
    @investment.project = Project.unallocated_project unless @investment.project.present?
    @project = @investment.project
    # Is this investment being made as a result of a promotion?
    if params[:promotion_id]
      promotion = Promotion.find(params[:promotion_id])
      if !promotion.nil?
        @investment.promotion = promotion
      end
    end

    respond_to do |format|
      format.html {
        if session[:gift_card_balance] && session[:gift_card_balance] > 0 && params[:unallocated_gift].present?
          # remove the auto-tip for directed gifts
          @cart.update_attributes(:add_optional_donation => false)
          render :action => 'confirm_unallocated_gift' and return 
        end
        if session[:gift_card_balance] && session[:gift_card_balance] > 0 && params[:directed_gift].present?
          # remove the auto-tip for directed gifts
          @cart.update_attributes(:add_optional_donation => false)
          render :action => 'confirm_directed_gift' and return
        end
        if session[:gift_card_balance] && session[:gift_card_balance] > 0 && params[:admin_gift].present?
          # remove the auto-tip for directed gifts
          @cart.update_attributes(:add_optional_donation => false)
          render :action => 'confirm_admin_gift' and return
        end
        if @project && @project != Project.unallocated_project && !@project.fundable?
          flash[:notice] = "The &quot;#{@project.name}&quot; is fully funded. Please choose another project."
          redirect_to dt_project_path(@project) and return
        end
      }
    end
  end

  def create
    @investment = Investment.new( params[:investment] )
    @investment.project_id = params[:project_id] if params[:project_id] && !@investment.project_id?
    @investment.user_id = current_user.id if logged_in?
    @investment.user_ip_addr = request.remote_ip
    @project = @investment.project if @investment.project

    @valid = @investment.valid?
    @cart.add_item(@investment) if @valid

    respond_to do |format|
      if @valid
        if @cart.subscription?
          format.html { redirect_to dt_cart_path(:skip_cart => 1) }
        else
          flash[:notice] = "Your Investment has been added to your cart."
          format.html { redirect_to dt_cart_path }
        end
      else
        format.html { render :action => 'new' }
      end
    end
  end

  def edit
    if @cart.items.find(params[:id]).item.kind_of?(Investment)
      @investment = @cart.items.find(params[:id]).item
      @project = @investment.project if @investment.project_id?
    end

    respond_to do |format|
      format.html {
        redirect_to dt_cart_path and return unless @investment
        render :action => "edit"
      }
    end
  end

  def update
    if @cart.items.find(params[:id]).item.kind_of?(Investment)
      @investment = @cart.items.find(params[:id]).item
      @investment.attributes = params[:investment]
      @investment.user_ip_addr = request.remote_ip
      @valid = @investment.valid?
    end

    respond_to do |format|
      if !@investment
        format.html { redirect_to dt_cart_path }
      elsif @valid
        @cart.update_item(params[:id], @investment)
        format.html {
          flash[:notice] = "Your Investment has been updated."
          redirect_to dt_cart_path
        }
      else
        @project = @investment.project if @investment.project_id?
        format.html { render :action => "edit" }
      end
    end
  end

  private
  def user_validation(user)
    user.errors.add_on_empty %w( first_name last_name address city province postal_code country )
  end
end
