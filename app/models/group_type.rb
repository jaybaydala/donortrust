class GroupType < ActiveRecord::Base
  acts_as_paranoid
  has_many :groups

  validates_presence_of     :name
  validates_uniqueness_of   :name


  def group_count
    return groups.count
  end
end
