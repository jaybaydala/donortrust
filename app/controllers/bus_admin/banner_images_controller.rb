class BusAdmin::BannerImagesController < ApplicationController
  
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'
  
  active_scaffold :banner_images do |config|
    config.columns =[ :model_id, :controller, :action, :file ]
    config.columns[ :file ].label = "Image File"
    config.create.multipart = true
    config.update.multipart = true      
  end
end


