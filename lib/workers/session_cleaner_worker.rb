class SessionCleanerWorker < BackgrounDRb::Worker::RailsBase
  def do_work(args)
    # This method is called in it's own new thread when you
    # call new worker. args is set to :args
    deleted_count = CGI::Session::ActiveRecordStore::Session.delete_all( ['updated_at <?', 20.minutes.ago] ) 
    logger.info "[#{Time.now.utc.to_s}] Deleted inactive sessions (#{deleted_count})"
  end
end
SessionCleanerWorker.register
