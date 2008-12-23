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
    @investment.project_id = params[:project_id] if params[:project_id]
    # load the unallocated_project if no other project is loaded
    @investment.project = Project.unallocated_project if (Project.unallocated_project && !@investment.project)
    @project = @investment.project if @investment.project
    
    # Is this investment being made as a result of a promotion?    
    if params[:promotion_id]
      promotion = Promotion.find(params[:promotion_id])
      
      if !promotion.nil?
        @investment.promotion = promotion
      end
      # Otherwise, someone has tried to hack the query string with any old rubbish

    end

    respond_to do |format|
      format.html {
        if session[:gift_card_balance] && session[:gift_card_balance] > 0 && params[:unallocated_gift] && !params[:unallocated_gift].empty?
          render :action => 'confirm_unallocated_gift' and return 
        end
        if session[:gift_card_balance] && session[:gift_card_balance] > 0 && params[:directed_gift] && !params[:directed_gift].empty? 
          render :action => 'confirm_directed_gift' and return
        end
        if session[:gift_card_balance] && session[:gift_card_balance] > 0 && params[:admin_gift] && !params[:admin_gift].empty?
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

    respond_to do |format|
      if @valid
        @cart.add_item(@investment)
        flash[:notice] = "Your Investment has been added to your cart."
        format.html { redirect_to dt_cart_path }
      else
        flash.now[:error] = "There was a problem adding the Investment to your cart. Please review your information and try again."
        format.html { render :action => 'new' }
      end
    end
  end

  def edit
    if @cart.items[params[:id].to_i].kind_of?(Investment)
      @investment = @cart.items[params[:id].to_i]
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
    if @cart.items[params[:id].to_i].kind_of?(Investment)
      @investment = @cart.items[params[:id].to_i]
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
