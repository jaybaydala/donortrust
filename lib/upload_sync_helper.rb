module UploadSyncHelper
  protected
  def sync_uploads
    system("cd #{RAILS_ROOT} && RAILS_ENV=#{ENV['RAILS_ENV']} script/sync_uploads") if %w(staging production).include?(ENV['RAILS_ENV'])
  end
end