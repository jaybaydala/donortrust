class Page < ActiveRecord::Base
  validates_presence_of :title, :permalink, :content

  has_many :wall_posts, :as => :postable, :dependent => :destroy

  before_save :generate_path
  before_validation :generate_permalink

  acts_as_nested_set

  def absolute_path
    "/#{self.path}"
  end

  def owned?(current_user)
    false
  end

  def title_with_level
    "#{'- '*self.level}#{self.title}"
  end

  protected
    def generate_permalink
      self.permalink = self.title.to_s.parameterize unless self.permalink?
    end

    def generate_path
      self.path = self.self_and_ancestors.map(&:permalink).join('/')
    end
end