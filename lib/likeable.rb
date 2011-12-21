module Likeable

  def self.included(base)
    base.has_many :likes, :as => :likeable
  end

  # network :- facebook, google, local
  def like(network, user)
    unless (network == 'local' && user.nil?)
      user_id = user.nil? ? nil : user.id
      likes.create(:network => network, :user_id => user_id) unless liked_by?(user, network)
    end
  end

  # returns likes count
  def likes_count
    likes.count
  end

  # handle facebook and google plus unlikes 
  def unlike(network)
    like = likes.find(:last, :conditions => {:network => network})
    like.destroy if like
  end

  def liked_by?(user, network)
    return false if user.nil?
    likes.find(:all, :conditions => {:network => network, :user_id => user.id}).present?
  end

end
