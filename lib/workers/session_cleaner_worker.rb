class SessionCleanerWorker < BackgrounDRb::MetaWorker
  set_worker_name :session_cleaner_worker
  reload_on_schedule true
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def do_work(args = nil)
    deleted_count = CGI::Session::ActiveRecordStore::Session.delete_all( ['updated_at <?', 20.minutes.ago] ) 
    logger.info "[#{Time.now.utc.to_s}] Deleted inactive sessions (#{deleted_count})"
  end
end
