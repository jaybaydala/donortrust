class Authentication < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
  
  def provider_name
    if provider == 'open_id'
      "OpenID"
    else
      provider.titleize
    end
  end
end
