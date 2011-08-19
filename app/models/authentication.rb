class Authentication < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  named_scope :facebook, :conditions => { :provider => "facebook" }
  named_scope :twitter, :conditions => { :provider => "twitter" }
  named_scope :google, :conditions => { :provider => "google" }

  def provider_name
    if provider == 'open_id'
      "OpenID"
    else
      provider.titleize
    end
  end
end
