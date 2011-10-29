class OldCampaign < ActiveRecord::Base
  attr_accessor :use_user_email

  after_create :create_default_team

  belongs_to :old_campaign_type
  belongs_to :creator, :class_name => 'User', :foreign_key => 'user_id'
  has_and_belongs_to_many :projects
  has_many :cause_limits
  has_many :causes, :through => :cause_limits
  has_many :investments
  has_many :news_items, :as => :postable, :dependent => :destroy
  has_many :old_participants, :through => :old_teams
  has_many :place_limits
  has_many :places, :through => :place_limits
  has_many :partner_limits
  has_many :partners, :through => :partner_limits
  has_many :pledges
  has_many :old_teams, :dependent => :destroy
  has_many :wall_posts, :as =>:postable, :dependent => :destroy
  has_one :default_team, :dependent => :destroy, :class_name => "OldTeam"
  has_one :pledge_account

  validates_format_of :postalcode, :with => /(\D\d){3}/, :if => :in_canada?, :allow_blank => true, :message => "In Canada the proper format for postal code is: A9A9A9, Where A is a leter between A-Z and 9 is a number between 0 - 9."
  validates_format_of :short_name, :with => /\w/, :message => "the short name must start with an alphabetic character (a-z)"
  validates_format_of :short_name, :with => /^[a-zA-Z0-9_]+$/, :message => "Short name can only contain letters, numbers, and underscores."
  validates_length_of :postalcode, :is => 5, :if => :in_usa?, :allow_blank => true
  validates_length_of :description, :minimum => 10
  validates_length_of :name, :within => 4..255
  validates_length_of :short_name, :within => 4...60
  validates_length_of :postalcode, :is => 6, :if => :in_canada?, :allow_blank => true
  validates_numericality_of :fundraising_goal, :fee_amount, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :postalcode, :if => :in_usa?, :allow_blank => true, :message => "Zip codes must be a number."
  validates_numericality_of :max_number_of_teams, :max_size_of_teams, :max_participants, :fee_amount, :greater_than_or_equal_to => 0, :only_integer => true, :allow_nil => true
  validates_presence_of :name, :campaign_type, :description, :fundraising_goal, :creator, :short_name
  validates_uniqueness_of :short_name, :message => "the short name is not unique"

  IMAGE_SIZES = {
    :full => {:width => 150, :height => 150, :modifier => ">"},
    :thumb => {:width => 75, :height => 75, :modifier => ">"}
  }
  has_attached_file :image, :styles => Hash[ *IMAGE_SIZES.collect{|k,v| [k, "#{v[:width]}x#{v[:height]}#{v[:modifier]}"] }.flatten ], 
    :whiny_thumbnails => true,
    :default_style => :normal,
    :convert_options => { 
      :all => "-strip" # strips metadata from images, removing potentially private info
    },
    :default_url => "/images/dt/icons/users/:style/missing.png",
    :storage => :s3,
    :bucket => "uend-images-#{Rails.env}",
    :path => ":class/:attachment/:id/:basename-:style.:extension",
    :s3_credentials => File.join(Rails.root, "config", "aws.yml")
  validates_attachment_size :image, :less_than => 1.megabyte, 
    :if => Proc.new {|c| c.image_file_name? }
  validates_attachment_content_type :image, :content_type => %w(image/jpeg image/gif image/png image/pjpeg image/x-png), # the last 2 for IE
    :if => Proc.new {|c| c.image_file_name? }
  # is_indexed :delta => true, 
  #   :fields => [
  #     {:field => 'name', :sortable => true},
  #     {:field => 'description'},
  #     {:field => 'city'},
  #     {:field => 'province'},
  #     {:field => 'country'}
  #   ], 
  #   :include => [
  #     {
  #       :class_name => 'Team',
  #       :field => 'teams.name',
  #       :as => 'team_name',
  #       :association_sql => "LEFT JOIN (teams) ON (teams.campaign_id=campaigns.id)"
  #     },
  #     {
  #       :class_name=> 'Team',
  #       :field => 'teams1.short_name',
  #       :as => 'team_short_name',
  #       :association_sql => "LEFT JOIN (teams as teams1) ON (teams1.campaign_id=campaigns.id)"
  #     },
  #     {
  #       :class_name => 'Team',
  #       :field => 'teams2.description',
  #       :as => 'team_description',
  #       :association_sql => "LEFT JOIN (teams as teams2) ON (teams2.campaign_id=campaigns.id)"
  #     }
  #   ]

  def before_validation
    if use_user_email == "1"
      self.email = current_user.email
    end

    #hard coding currency
    self.fee_currency = "CDN"
    self.goal_currency = "CDN"

    #self.pending = true

    self.postalcode = postalcode.sub(' ', '') if not postalcode.blank? # remove any spaces.
  end

  def update_attributes(attributes=nil)
    projects.clear
    super
  end

  def can_be_closed?(current_user=nil)
    if current_user.present? && owned?(current_user) && !funds_allocated
      if Time.now.utc > raise_funds_till_date.utc
        if Time.now.utc < allocate_funds_by_date.utc
          return true
        end
      end
    end
    return false
  end
  
  def close!(attribute_to_campaign_owner = false)
    return if self.funds_allocated? || self.funds_raised == 0
    Order.transaction do
      user = attribute_to_campaign_owner == true ? self.creator : User.campaign_allocations_user
      pledge_account = PledgeAccount.create_from_campaign!(self)
      unless pledge_account.new_record?
        # this feels really cheesy to me somehow
        funds_left = pledge_account.balance
        possible_projects = projects_for_contribution
        transactions = []
        possible_projects.each do |p|
          break if funds_left <= 0
          investment_amount = p.current_need < funds_left ? p.current_need : funds_left
          transactions << Investment.new(:amount => investment_amount, :project => p, :user => self.creator)
          funds_left -= investment_amount
        end
        if funds_left > 0
          transactions << Deposit.new(:amount => funds_left, :user => User.allocations_user)
          funds_left = 0
        end

        # put the transactions in the cart
        cart = Cart.create!(:user_id => self.creator.id, :add_optional_donation => false)
        transactions.each{|t| cart.add_item(t) if t.amount.present? && t.amount > 0 }

        order = Order.new({
          :first_name => self.creator.first_name,
          :last_name => self.creator.last_name,
          :email => self.creator.email,
          :user => self.creator,
          :pledge_account_payment => pledge_account.balance,
          :pledge_account_payment_id => pledge_account.id,
          :complete => true
        })
        order.investments = cart.investments.select{|t| t.amount.present? && BigDecimal.new(t.amount.to_s) > 0 }
        order.deposits = cart.deposits.select{|t| t.amount.present? && BigDecimal.new(t.amount.to_s) > 0 }
        order.total = cart.total
        order.notes = "Transactions for the &quot;#{self.name} (#{self.id})&quot; Campaign closing:<br />\n"
        if order.investments.present?
          order.notes += "Investments: #{order.investments.map{|i| "#{i.project.name}: #{i.amount}"}.join(', ')}\n"
        end
        if order.deposits.present?
          order.notes += "Deposit: #{order.deposits.map{|d| "#{d.user.full_name}: #{d.amount}"}.join(', ')}\n"
        end
        order.validate_confirmation(cart)
        order.save!
        self.update_attribute(:funds_allocated, true)
        return order
      end
    end
  end

  def validate
    errors.add('start_date',"must be before the event date.") if start_date > event_date
    errors.add('start_date',"must be before the \"Raise Funds Till\" date.") if start_date > raise_funds_till_date
    errors.add('allocate_funds_by_date',"must be after the \"Raise Funds Till\" date.") if allocate_funds_by_date < raise_funds_till_date
    errors.add('email',"Must provide an email to use for contact." ) if email.blank?
    errors.add('postalcode',"Is not correct for your province") if in_canada? && postalcode? && !postalcode_matches_province?
    errors.add('postalcode',"Is not correct for your state") if in_usa? && postalcode? && !zipcode_matches_state?
  end

  def has_project?(project)
    projects.each do |p|
      if project == p
        return true
      end
    end
    return false
  end

  def funds_raised
    total = self.pledges.inject(0) do |sum, pledge|
      sum = sum + ( pledge.paid? ? pledge.amount : 0)
    end
    total = self.teams.inject(total) do |sum, t|
      sum = sum + t.funds_raised
    end

    total
  end

  def eligible_projects
    Project.find_by_sql("SELECT p.* FROM projects p, causes_limit JOIN causes_limit ON ")
  end

  def has_registration_fee?
    fee_amount.to_f > 0
  end

  def teams_full?
    return (self.teams.size >= self.max_number_of_teams if self.max_number_of_teams?)
  end

  def percentage_done
    raised = ((self.funds_raised.to_f/self.fundraising_goal.to_f)*100).round(0).to_i
    "#{raised} %"
  end

  def manage_link
    (link_to('Manage Campaign',manage_dt_campaign_path(self)) + " | ") unless not self.owned?
  end

  def fundraising_goal_with_currency
    "#{self.fundraising_goal} #{self.goal_currency}"
  end

  def campaign_fee_with_currency
    "#{self.fee_amount} #{self.fee_currency}"
  end

  def is_active?
    self.active == true
  end

  def in_canada?
    country == 'Canada'
  end

  def in_usa?
    country == 'United States'
  end

  # Check for ownership of this campaign
  def owned?(user_to_check = current_user)
    user_to_check ? self.creator == user_to_check : false
  end

  def activate!
    self.update_attribute(:pending, false)
  end

  def pending_teams
    Team.find_all_by_campaign_id_and_pending(self.id, true)
  end

  def active_teams
    Team.find_all_by_campaign_id_and_pending(self.id, false)
  end

  def can_join_team?(user)
    #if the user is on the default team then we can still join another team
    if (self.default_team.users.include?(user)) then
      puts "user is on default team"
      return false
    end

    #see if the user is on another team
    if (participants.include?(user)) then
      puts "user is on another team"
      return false
    end

    return true
  end

  def participating?(user)
    participants.include?(user)
  end
  
  def active_participants
    Participant.find_by_sql(["SELECT p.* FROM participants p, teams t WHERE p.team_id = t.id AND t.campaign_id = ? AND p.pending = 0 AND p.active = 1",self.id])
  end
  
  def active_and_current_participants
    active_participants
  end

  def not_pending_participants
    @participants = Participant.find_by_sql(["SELECT p.* FROM participants p, teams t WHERE p.team_id = t.id AND t.campaign_id = ? AND p.pending = 0",self.id])
  end
  
  def pending_participants
    @participants = Participant.find_by_sql(["SELECT p.* FROM participants p, teams t WHERE p.team_id = t.id AND t.campaign_id = ? AND p.pending = 1",self.id])
  end

  def has_participant(user)
    users = User.find_by_sql(["SELECT u.* FROM users u, teams t, participants p WHERE p.user_id = u.id AND p.team_id = t.id AND t.campaign_id = ? AND u.id = ?",self.id, user])
    users.first ? true : false;
  end

  def generic_team
    Team.find_by_campaign_id_and_generic(self.id, true)
  end

  private
    # check that the postalcode follows the canadian standard for postal codes, see http://en.wikipedia.org/wiki/Canadian_postal_code
    def postalcode_matches_province?
      provinceHash = Hash.new
      provinceHash['NL'] = /A/i
      provinceHash['NS'] = /B/i
      provinceHash['PE'] = /C/i
      provinceHash['NB'] = /E/i
      provinceHash['QC'] = /G|H|J/i
      provinceHash['ON'] = /K|L|M|N|O|P/i
      provinceHash['MB'] = /R/i
      provinceHash['SK'] = /S/i
      provinceHash['AB'] = /T/i
      provinceHash['BC'] = /V/i
      provinceHash['NT'] = /X/i
      provinceHash['NU'] = /X/i
      provinceHash['YT'] = /Y/i
      (provinceHash[province] =~ postalcode) == 0
    end

    #check that the zip code follows the american standard, see http://en.wikipedia.org/wiki/Zip_code
    def zipcode_matches_state?
      zipArray = Array.new
      zipArray[0] = /CT|MA|ME|NH|NJ|RI|VT/
      zipArray[1] = /DE|NY|PA/
      zipArray[2] = /DC|MD|NC|SC|VA|WV/
      zipArray[3] = /AL|FL|GA|MS|TN/
      zipArray[4] = /IN|KY|MI|OH/
      zipArray[5] = /IA|MN|MT|ND|SD|WI/
      zipArray[6] = /IL|KY|MO|NE/
      zipArray[7] = /AR|LA|OK|TX/
      zipArray[8] = /AZ|CO|ID|NM|NV|UT|WY/
      zipArray[9] = /AK|CA|HI|OR|WA/
      (zipArray[postalcode.chars.first.to_i] =~ province) != nil
    end

    def create_default_team
      unless self.allow_multiple_teams? # if only one team is allowed build the container team.
        self.teams.create(:name => self.name, :short_name => self.short_name, :description => self.description, :goal => self.fundraising_goal, :contact_email => self.email, :user_id => self.user_id, :pending => 0)
      end
    end
    
    def projects_for_contribution
      projects_for_contribution = if self.projects.empty?
        admin_projects = [Project.admin_project, Project.unallocated_project].compact
        conditions = []
        if admin_projects.present?
          conditions << 'id not in (?)'
          conditions << admin_projects.map(&:id)
        end
        Project.all(:conditions => conditions)
      else
        self.projects
      end
      projects_for_contribution = projects_for_contribution.select{|p| p.current_need > 0 }
    end
end
