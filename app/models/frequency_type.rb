class FrequencyType < ActiveRecord::Base
  acts_as_paranoid
  has_many :key_measures

  validates_presence_of :name  #, :active
  validates_uniqueness_of :name

  def indicator_measurement_count
    return key_measures.count
  end
end
