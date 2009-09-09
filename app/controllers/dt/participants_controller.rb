require 'order_helper'
class Dt::ParticipantsController < DtApplicationController
  helper "dt/places"
  include OrderHelper

  before_filter :find_team, :only => [:new, :create]
  before_filter :login_required, :except => [:show, :index, :new, :create]
  before_filter :is_authorized?, :only => [:update, :manage, :admin]
  include UploadSyncHelper
  after_filter :sync_uploads, :only => [:create, :update, :destroy]
  helper "dt/places"
  helper "dt/forms"
  helper_method :current_step
  helper_method :next_step

  CHECKOUT_STEPS = ["support", "payment", "billing", "confirm"]

  helper_method :summed_account_balances

  def show
    store_location

    @participant = Participant.find(params[:id]) unless params[:id].nil?
    @participant = Participant.find_by_short_name(params[:short_name]) if @participant.nil? && !params[:short_name].nil?
    # old participant records still exist when a campaign/team gets deleted. A participant must belong to a team and a campaign
    unless @participant && @participant.team && @participant.team.campaign
      flash[:notice] = 'That campaign / participant could not be found. Please choose a current campaign.'
      redirect_to dt_campaigns_path and return
    end
    # raise ActiveRecord::RecordNotFound unless @participant.team && @participant.team.campaign

    @campaign = Campaign.find_by_short_name(params[:short_campaign_name]) unless params[:short_campaign_name].nil?
    @team = Team.find_by_short_name(params[:team_short_name]) unless params[:team_short_name].nil?

    if @team != nil and @user != nil
      @participant = Participant.find_by_user_id_and_team_id(@user.id, @team.id)
    elsif @user != nil and @campaign != nil
      for participant in @campaign.participants
        if participant.user == @user
          @participant = participant
        end
      end
    end

    if @campaign == nil && @participant != nil && @participant.team
      @campaign = @participant.team.campaign
    end

    if @participant == nil
      flash[:notice] = 'That campaign / participant could not be found. Please choose a current campaign.'
      redirect_to dt_campaigns_path and return
    end

    @can_sponsor_participant = false
    if not @participant.pending
      if not @participant.team.pending
        if not @campaign.pending
          if @campaign.start_date.utc < Time.now.utc
            if @campaign.raise_funds_till_date.utc > Time.now.utc
              @can_sponsor_participant = true
            end
          end
        end
      end
    end
  end

  def new
    store_location
    @participant = Participant.new
    
    if not @team.campaign.valid?
      flash[:notice] = "The campaign is not currently active, you are not able to join or leave teams."
      redirect_to dt_team_path(@team)
    end

    if (current_user == :false)
      return
    end

    @participant.user = current_user
    @participant.team_id = @team.id

    #check and see if the user is part of the campaign already
    campaign = nil
    
    current_user.campaigns.each do |c|
      if (c.id == @team.campaign.id)
        campaign = c;
      end
    end
    
    if (campaign != nil)
      #if they are check and see if they are in the default team
      if (campaign.default_team.has_user?(current_user))
        @participant = campaign.default_team.participant_for_user(current_user)
        @participant.team_id = @team.id
        @participant.save

        flash[:notice] = 'Team joined successfully'
        redirect_to(dt_team_path(@team))
      else
        #output some error messages if they are on the campaign
        # This user has already signed up for this campaign
        existing_participant = Participant.find(:first, :conditions => [ "user_id = ? AND team_id = ?", current_user.id, @team.id ])
        if (existing_participant == nil)
          flash[:notice] = "You are already taking part in the " + @team.campaign.name + 
                           " campaign as a member of a different team, so you can't join " + @team.name + "."
          redirect_to dt_campaign_path(@team.campaign) 

        elsif (existing_participant.pending)
          flash[:notice] = "You have already applied to take part in the " + @team.campaign.name + 
                           " campaign as a member of " + @team.name + " but have not yet been approved."
          redirect_to dt_campaign_path(@team.campaign) 

        else
          flash[:notice] = "You are already taking part in the " + @team.campaign.name +
                           " campaign. This is your campaign page."
          redirect_to dt_participant_path(existing_participant) 
        end
      end
    end
  end

  def create
    
    @participant = Participant.new(params[:participant])
    
    if not @team.nil?
      if not @team.campaign.valid?
        flash[:notice] = "The campaign has ended, you are not able to join or leave teams."
        redirect_to dt_team_path(@team)
      end
      
      #validating we have filled in the information that is required
      logger.debug("Checking short name for save.")
      if validate_short_name_of == false
        flash[:notice] = "Errors in your profile URL. Please make sure you have one entered and that it is valid."
        redirect_to :action => "new", :team_id => @team.id and return
      end
      
    end
    
    if current_user == :false
      # If the user is not logged in check the user details that have been 
      # passed through in the params. Use the details to 
      # create a new account
      new_user = User.new
      new_user.login = @participant.new_reg_login
      new_user.password = @participant.new_reg_password
      new_user.password_confirmation = @participant.new_reg_password_confirm
      new_user.display_name = @participant.new_reg_display_name
      new_user.country = @participant.new_reg_country
      new_user.terms_of_use = @participant.new_reg_terms_of_use

      begin
        if new_user.save!
          new_user.activate
          
          # TODO: This login code has been stolen from the sessions_controller "create" action - is there a more elegant and DRY way to do this?
          self.current_user = User.authenticate(new_user.login, new_user.password)
          current_user.update_attributes(:last_logged_in_at => Time.now)
          session[:tmp_user] = nil
          cookies[:dt_login_id] = self.current_user.id.to_s
          cookies[:dt_login_name] = self.current_user.name
        else # Something went wrong with saving the user        
          
          # HACK! At this point, we know the user cannot be logged in (after all, they are trying to create new user details)
          # so before sending them back to the form to correct whatever caused the problem, we need to associate a new
          # user object with the participant to avoid a "Called id for nil, which would mistakenly be 4" error when the 
          # new.html.erb page is rendered again
          @participant.user = User.new

          render :action => "new"
          return
        end
      rescue ActiveRecord::RecordInvalid => invalid
       
         #TODO: Why am I having to construct this error message manually? I know I can't just pass the errors back to 
         #      the form because the form thinks it's dealing with a participaant object. But is there a better way?
         error_message = "<p>Could not create user:</p><ul>"
         invalid.record.errors.each_full{|msg| error_message << "<li>" + msg + "</li>" }
         error_message << "</ul>"
         flash[:error] = error_message

         # HACK! At this point, we know the user cannot be logged in (after all, they are trying to create new user details)
         # so before sending them back to the form to correct whatever caused the problem, we need to associate a new
         # user object with the participant to avoid a "Called id for nil, which would mistakenly be 4" error when the 
         # new.html.erb page is rendered again
         @participant.user = User.new 
         
         render :action => "new"
         return
      end

      @participant.user = new_user
    else
      @participant.user = current_user
    end

    if @team.require_authorization
      @participant.pending = true
    else
      @participant.pending = false
    end

    #if the user was part of the default team, remove them from that team and put them in this one
    if (@team.campaign.default_team.has_user?(current_user)) then
      default_participant = @team.campaign.default_team.participant_for_user(current_user)
      default_participant.team_id = @team.id
      
      if default_participant.save
        redirect_to dt_participant_path(@participant) and return
      else
        render :action => 'new' and return
      end

    else
      @participant.team_id = @team.id

      if @team.campaign.has_registration_fee? and not @participant.has_paid_registration_fee? #there is something wrong with this
        @current_step = "payment"

        unpaid_participant = UnpaidParticipant.new( :user_id => @participant.user_id, 
                                                    :team_id => @participant.team_id,
                                                    :short_name => @participant.short_name,
                                                    :pending => @participant.pending,
                                                    :private => @participant.private,
                                                    :about_participant => @participant.about_participant,
                                                    :picture => @participant.picture,
                                                    :goal => @participant.goal )

        if @participant.errors.empty?
          
          if unpaid_participant.errors.empty? && unpaid_participant.save
          else
            flash[:notice] = "Filesize for profile photo is too big.  Please use one under 500k."
            redirect_to :action => "new", :team_id => @team.id and return
          end
          
        else
          flash[:notice] = "Filesize for profile photo is too big.  Please use one under 500k."
          redirect_to :action => "new", :team_id => @team.id and return
        end

        #create the item
        registration_fee = RegistrationFee.new
        registration_fee.amount = @team.campaign.fee_amount
        registration_fee.participant_id = unpaid_participant.id
        registration_fee.save

        unpaid_participant.registration_fee_id = registration_fee.id
        unpaid_participant.save

        @cart = find_cart

        #clear the cart
        @cart.empty!

        #add it to the cart
        @cart.add_item(registration_fee)

        #if the cart has other items go to the first stage of the checkout
        if (@cart.items.size > 1)
          redirect_to new_dt_checkout_url and return
        end

        #initialize the order
        @order = initialize_new_order
        @order.total = registration_fee.amount
        @order.credit_card_payment = registration_fee.amount
        @order.email = current_user.email
        @order.tax_receipt = nil
        @order.is_registration = 1
        @order.registration_fee_id = registration_fee.id

        @valid = validate_order

        @saved = @order.save if @valid

        # save our order_id in the session
        session[:order_id] = @order.id if @saved

        registration_fee.order_id = @order.id
        registration_fee.save
        
        #run the setup for the billing step
        before_payment
        before_billing

        @current_nav_step = next_step
        redirect_to edit_dt_checkout_path(:step => "billing") and return

      else
      
        @participant.save
        redirect_to dt_participant_path(@participant) and return
      end
    
    end
  end

  def validate_short_name_of
    
    @valid = true
    
    @errors = Array.new
    
    if params[:participant_short_name] == "" || params[:participant_short_name].nil?
      logger.debug("other path")
      @short_name = @participant.short_name
    else
      logger.debug("parameter path")
      @short_name = params[:participant_short_name]
    end
    
    if params[:campaign_id] == "" || params[:campaign_id].nil?
      @campaign_id = @team.campaign.id
    else
      @campaign_id = params[:campaign_id]
    end  

    if @short_name != nil
      @short_name.downcase!
      
      if(@short_name =~ /\W/)
        logger.debug("Invalid characters in shortname")
        @errors.push('You may only use Alphanumeric Characters, hyphens, and underscores. This also means no spaces.')
        @valid = false;
      end

      if(@short_name.length < 3)
        logger.debug("Invalid length of shortname")
        @errors.push('The short name must be 3 characters or longer.')
        @valid = false
      end

      participants_shortname_find = Participant.find_by_sql([
        "SELECT p.* FROM participants p INNER JOIN teams t INNER JOIN campaigns c " +
        "ON p.team_id = t.id AND t.campaign_id = c.id "+
        "WHERE p.short_name = ? AND c.id = ?",@short_name, @campaign_id])

      if(participants_shortname_find != nil && !participants_shortname_find.empty? )
        logger.debug("Non unique shortname")
        @errors.push('That short name has already been used, short names must be unique to each campaign.')
        @valid = false
      end
    else
      logger.debug("Reserved characters in shortname")
      @errors.push('The short name may not contain any reserved characters such as ?')
      @valid = false
    end
    [@errors, @short_name]
    
    return @valid
  end


  def update
    @participant = Participant.find(params[:id])

    if not @participant.team.campaign.valid?
      flash[:notice] = "The campaign has ended, you are not able to join or leave teams."
      redirect_to dt_team_path(@team)
    end

    if @participant.update_attributes(params[:participant])
      if not params[:team_id].nil?
        @participant.team_id = params[:team_id]
        @participant.save
      end
      flash[:notice] = 'Page successfully updated.'
      redirect_to(dt_participant_path(@participant))

    else
      render :action => "manage"
    end
  end

  def manage
    @participant = Participant.find(params[:id])
  end

  def admin
    @campaigns = Campaign.find_all_by_pending(false)
  end

  def activate
    participant = Participant.find(params[:id])

    participant.pending = false
    participant.save

    flash[:notice] = "User has been activated"
    redirect_to(request.env["HTTP_REFERER"])
  end

  def index
    @participant_having_object = nil #This is either a team or a campaign

    if params[:campaign_id] != nil
      @participant_having_object = Campaign.find(params[:campaign_id])
      @campaign = @participant_having_object
    elsif params[:team_id] != nil
      @participant_having_object = Team.find(params[:team_id])
      @team = @participant_having_object
      @campaign = @team.campaign
    end

    participants_array = @participant_having_object.participants.collect

    @participants = participants_array.paginate :page => params[:page], :per_page => 20
  end

  def destroy
    @participant = Participant.find(params[:id])
    @campaign = @participant.team.campaign

    @participant.team_id = @campaign.default_team.id
    @participant.save

    if params[:campaign_id] != nil
      redirect_to manage_dt_campaign(Campaign.find(params[:campaign_id]))
    elsif params[:team_id] != nil
      redirect_to manage_dt_campaign(Team.find(params[:team_id]))
    else
      redirect_to(dt_campaign_path(@campaign))
    end
  end

  def approve
    @participant = Participant.find(params[:id]) unless params[:id] == nil
    @team = @participant.team
    if @participant.approve!
      flash[:notice] = "#{@participant.name} approved!"
      redirect_to manage_dt_team_path(@team)
      # send email to participant when approved
      CampaignsMailer.deliver_participant_approved(@participant.campaign, @participant.team, @participant)
    else
      flash[:notice] = "There was an error approving that participant, please try again."
    end
  end

  # assign participant to generic team and approve
  def decline
    assign_participant_to_generic_team(params[:id])
    if @participant.approve!
      flash[:notice] = "#{@participant.name} assigned to #{@campaign.name} with with no team."
      redirect_to manage_dt_team_path(@team)
      # send email to participant when approved
      CampaignsMailer.deliver_participant_declined(@participant.campaign, @participant.team, @participant)
    else
      flash[:notice] = "There was an error declining that participant, please try again."
    end

  end

  protected
  def access_denied
    if ['join', 'create'].include?(action_name) && !logged_in?
      flash[:notice] = "You must have an account to join this campaign as a participant. Log in below, or "+
      "<a href='/dt/signup'>click here</a> to create an account."
      store_location
      respond_to do |accepts|
        accepts.html { redirect_to dt_login_path and return }
      end
    elsif ['manage'].include?(action_name) && !logged_in?
      flash[:notice] = "You must be logged in to manage your participant account.  Please log in."
      store_location
      respond_to do |accepts|
        accepts.html { redirect_to dt_login_path and return }
      end
    end
    super
  end


  private
  def find_team
    @team = Team.find(params[:team_id])
  end

  def is_authorized?
    @participant = Participant.find(params[:id])
    if @participant.user != current_user and not current_user.is_cf_admin?
      flash[:notice] = 'You are not authorized to see that page.'
      redirect_to dt_participant_path(@participant)
    end
  end

  private
  def assign_participant_to_generic_team(participant_id)
    @participant = Participant.find(participant_id) unless participant_id == nil
    @team = @participant.team
    @campaign = @team.campaign
    @participant.team = @campaign.generic_team
  end

  attr_accessor :current_step
  def current_step
    if @current_step.nil?
      @current_step = nil unless params[:step]
      @current_step = params[:step] if params[:step] && CHECKOUT_STEPS.include?(params[:step])
    end
    @current_step
  end
  
  def next_step
    next_step = CHECKOUT_STEPS[current_step ? CHECKOUT_STEPS.index(current_step)+1 : 0]
  end
  
  def validate_order
    user_balance = logged_in? ? current_user.balance : nil
    case current_step
      when "support"
        # no model validation to happen here
        @valid = true
      when "payment"
        @valid = @order.validate_payment(@cart.items)
      when "billing"
        @valid = @order.validate_billing(@cart.items)
      when "confirm"
        @valid = @order.validate_confirmation(@cart.items)
    end
    @valid
  end

  def before_payment
    # remove the payment info so we never keep it around
    @order.card_number = nil
    @order.cvv = nil
    @order.expiry_month = nil
    @order.expiry_year = nil
    @order.cardholder_name = nil
  end

  def before_billing
    # load the info from the first gift into the billing fields
    # gift = @cart.gifts.first if @cart.gifts.size > 0
    # if gift
    #   @order.email = gift.email unless @order.email?
    #   first_name, last_name = gift.name.to_s.split(/ /, 2)
    #   @order.first_name = first_name unless @order.first_name?
    #   @order.last_name = last_name unless @order.last_name?
    # end
  end
  
end
