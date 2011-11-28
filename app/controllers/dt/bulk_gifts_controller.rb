require 'order_helper'

class Dt::BulkGiftsController < DtApplicationController
  helper "dt/places"
  before_filter :login_required, :only => :unwrap
  before_filter :set_time_zone, :only => [ :create, :update ]
  before_filter :add_user_to_params, :only => [ :create, :update ]
  before_filter :find_cart
  include OrderHelper

  CANADA = 'canada'

  def new
    load_ecards
    @gift = Gift.new(:e_card => @ecards.first)
    @gift.send_email = nil # so we can preselect "now" for delivery
    @gift.email = current_user.email if !@gift.email? && logged_in?
    @gift.name = current_user.full_name if !@gift.name? && logged_in?

    if params[:project_id] && @project = Project.find(params[:project_id])
      if @project.fundable?
        @gift.project = @project
      else
        flash.now[:notice] = "The &quot;#{@project.name}&quot; is fully funded. Please choose another project."
      end
    end

    # Is this gift being given as a result of a promotion?
    if params[:promotion_id] && Promotion.exists?(params[:promotion_id])
      @gift.promotion_id = params[:promotion_id]
    end

    respond_to do |format|
      format.html {}
      format.js
    end
  end

  def create
    @gift = Gift.new( params[:gift] )
    @gift.user_ip_addr = request.remote_ip
    if params[:gift][:to_emails] && !params[:gift][:to_emails].empty?
      @gifts = []
      @errors = []
      email_parser = EmailParser.new(params[:gift][:to_emails], params[:remove_dups] == '1')
      email_parser.parse_lines
      if email_parser.errors.empty?
        email_parser.emails.each do |email|
          logger.debug("working on email #{email}")
          gift = @gift.clone
          gift.to_name = email.name
          gift.to_email = email.address
          gift.to_email_confirmation = email.address
          @errors << gift unless gift.valid?
          @gifts << gift
        end
      else
        logger.debug "EMAIL parse error"
      end

      respond_to do |format|
        if @errors.empty? && email_parser.errors.empty?
          find_cart
          @gifts.each{|gift| @cart.add_item(gift)}
          flash[:notice] = "Your Gifts have been added to your cart."
          format.html { redirect_to dt_cart_path }
        else
          @gift = @gifts.first unless @gifts.empty?
          @gift.errors.add_to_base("There were some invalid email addresses in your recipient list. Please fix them to continue: <strong>#{email_parser.errors.join(', ')}</strong><br /><strong>Please Note:</strong> the list must be separated by commas") unless email_parser.errors.empty?
          @project = @gift.project if @gift.project_id? && @gift.project
          load_ecards
          format.html { render :action => "new" }
        end
      end
    else
      begin
        @valid = @gift.valid?
      rescue ActiveRecord::MultiparameterAssignmentErrors
        fix_date_params!
        @gift = Gift.new( params[:gift] )
        @gift.errors.add_to_base("Please choose a valid delivery date for your gift")
        @gift.user_ip_addr = request.remote_ip
        @valid = false
      end

      respond_to do |format|
        if @valid
          @cart.add_item(@gift)
          format.html {
            flash[:notice] = "Your Gift has been added to your cart."
            redirect_to dt_cart_path
          }
          format.js
        else
          @project = @gift.project if @gift.project_id? && @gift.project
          load_ecards
          format.html { render :action => "new" }
          format.js
        end
      end
    end
  end

  protected
    def load_ecards
      @ecards = ECard.find(:all, :order => :id)
      @ecards.unshift(@ecards.delete_at(2)) unless @ecards.empty? # changing the default image
    end

    def fix_date_params!
      params[:gift].delete_if{ |key,value| key.to_s[0,8] == "send_at(" }
    end

    def add_user_to_params
      unless params[:gift].nil?
        params[:gift][:user] = current_user if logged_in?
      end
    end

    def gift_params
      gift_params = {}
      gift_params = gift_params.merge(params[:gift]) if params[:gift]
      normalize_send_at!(gift_params)
      gift_params
    end

    def normalize_send_at!(gift_params)
      delete_send_at = false
      (1..5).each do |x|
        delete_send_at = true if gift_params["send_at(#{x}i)"] == '' || !gift_params["send_at(#{x}i)"]
      end
      if delete_send_at
        (1..5).each do |x|
          gift_params.delete("send_at(#{x}i)")
        end
      end
    end

    # this does the actually time-shifting for scheduling the gift?
    def set_time_zone
      Time.zone = params[:time_zone] if params[:time_zone]
    end
end
