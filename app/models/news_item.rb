class NewsItem < ActiveRecord::Base
  belongs_to :postable, :polymorphic => true
  belongs_to :author, :class_name => "User", :foreign_key => "user_id"
  has_many :news_comments
  
  def owned?
    self.author == current_user
  end
  
end
