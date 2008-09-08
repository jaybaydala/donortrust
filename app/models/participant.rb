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
  
  
  def owned?
    current_user != nil ? self.user == current_user : false;
  end
  
  def name
    self.user.full_name
  end
  
  def funds_raised
    total = 0;
    for deposit in self.deposits
      total = total + deposit.amount
    end
    total
  end
  
  def short_about_participant
    short_about_participant = (self.about_participant.length > 100) ? self.about_participant[0...100] + '...' : self.about_participant
  end
  
end
