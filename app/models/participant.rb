class Participant < ActiveRecord::Base
  belongs_to :user
  belongs_to :team
  belongs_to :campaign

  has_many :wall_posts, :as =>:postable, :dependent => :destroy
  has_many :news_items, :as =>:postable, :dependent => :destroy

  has_many :pledges

  has_many :deposits, :through => :pledges

  image_column  :picture,
                :versions => { :thumb => "100x100", :full => "200x200"  },
                :filename => proc{|inst, orig, ext| "participant_#{inst.id}.#{ext}"},
                :store_dir => "uploaded_pictures/participant_pictures"

  validates_size_of :picture, :maximum => 500000, :message => "might be too big, must be smaller than 500kB!", :allow_nil => true

  validates_numericality_of :goal
  validates_uniqueness_of :user_id, :scope => :team_id

  def owned?
    current_user != nil ? self.user == current_user : false;
  end

  def name
    self.user.full_name
  end

  def funds_raised
    total = 0;
    for pledge in self.pledges
      if pledge.paid
        total = total + pledge.amount
      end
    end
    total
  end

  def short_about_participant(length = 100)
    short_about_participant = (self.about_participant.length > length) ? self.about_participant[0...length] + '...' : self.about_participant
  end

  def percentage_raised
    if self.goal?
      "#{(self.funds_raised / self.goal)*100 } %"
    else
      "n/a"
    end
  end

end
