module UploadSyncHelper
  protected
  def sync_uploads
    system("cd #{RAILS_ROOT} && cap #{ENV['RAILS_ENV']} deploy:sync_uploads")
  end
end