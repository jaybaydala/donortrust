class Collaboration < ActiveRecord::Base
  belongs_to :project
  belongs_to :collaborating_agency
end
