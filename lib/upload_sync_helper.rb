module UploadSyncHelper
  protected
  def sync_uploads
    "cd #{RAILS_ROOT} && cap #{ENV['RAILS_ENV']} deploy:sync_uploads"
  end
end