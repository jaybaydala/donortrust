class ApplicationSetting < ActiveRecord::Base
  validates_presence_of :name, :slug, :value
  validates_uniqueness_of :slug
end