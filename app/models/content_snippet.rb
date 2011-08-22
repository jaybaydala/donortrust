class ContentSnippet < ActiveRecord::Base
  validates_presence_of :title, :slug, :body
  validates_uniqueness_of :slug

  before_save :load_slug

  def body_formatted
    self.body.gsub(/\n/, "<br>\n")
  end

  private
    def load_slug
      self.slug = self.title.parameterize unless self.slug?
    end
end
