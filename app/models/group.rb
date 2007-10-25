class Group < ActiveRecord::Base
  belongs_to :group_type
  has_many :investments
  has_many :memberships
  has_many :users, :through => :memberships
  #has_many :users, :through => :groupwall
  #has_many :users, :through => :group_admin_notes
  has_and_belongs_to_many :projects
  belongs_to :place

  validates_presence_of :name
  validates_inclusion_of :private, :in => [true, false]

  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.group_type( true )
      me.errors.add :group_type_id, 'does not exist'
    end
    
    #need to validate the presence of other featured groups
    #  there cannot be more than 5 featured groups
    if me.featured == true
      if Group.count("featured = 1") >= 5
        me.errors.add "There are already 5 featured groups."
      end
    end
  end

  def project_count
    return projects.count
  end

  def user_count
    return users.count
  end

  def founder
    Membership.find_group_founder(self[:id])
  end
  
  def raised
    @raised ||= calculate_raised
  end
  
  def causes
    @causes ||= calculate_causes
  end
  
  def lives_affected
    @lives_affected ||= calculate_lives_affected
  end

  def member(user)
    memberships.find_by_user_id(user.id)
  end
  
  def place
    @place ||= calculate_place
  end
  
  def place?
    place.empty? ? false : true
  end
  
  protected
  def calculate_place
    str = ''
    %w( city province country ).each do |place|
      str+=', ' unless str.empty? || str[2,-2] == ', '
      str+=send("#{place}") if send("#{place}?")
    end
    str
  end
  
  def calculate_raised
    members = ''
    Group.find(self[:id]).memberships.each do |member|
      members+=" OR " unless members.empty?
      members+="user_id=#{member.user_id}"
    end
    raised = 0
    unless members.empty?
      Investment.find(:all, :conditions =>"group_id=#{self[:id]} AND (#{members})").each do |investment|
        raised+=investment.amount
      end
    end
    raised
  end
  
  def calculate_causes
    causes = []
    projects.find(:all, :include => :causes).each do |project|
      project.causes.each do |cause|
        causes << cause unless causes.include?(cause)
      end
    end
    causes
  end

  def calculate_lives_affected
    lives = 0
    projects.find(:all).each do |project|
      lives += project.lives_affected if project.lives_affected?
    end
    lives
  end
end
