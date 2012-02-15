class ProjectPoi < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates_presence_of :project_id, :name, :email
  before_create :make_token

  private
    TOKEN_SYMBOLS = (('A'..'Z').to_a + ('a'..'z').to_a + (0..9).to_a)
    def make_token
      self.token = (1..12).inject(""){|token, num| token += TOKEN_SYMBOLS.rand.to_s }
      make_token if self.class.find_by_token(self.token)
      self.token
    end

end
