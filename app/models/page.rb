class Page < ActiveRecord::Base
  validates_presence_of :title, :permalink, :content
  validates_uniqueness_of :title, :scope => :parent_id

  has_many :wall_posts, :as => :postable, :dependent => :destroy

  acts_as_nested_set

  before_validation :generate_permalink

  # the path-specific callbacks must come after the acts_as_nested_set call
  after_save :generate_and_save_permalink

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

    def generate_and_save_permalink
      path = self.self_and_ancestors.map(&:permalink).join('/')
      Page.update_all("path='#{path}'", {:id => self.id})
      self.reload
    end
end