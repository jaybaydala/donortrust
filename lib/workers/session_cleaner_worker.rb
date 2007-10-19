class SessionCleanerWorker < BackgrounDRb::Worker::RailsBase
  def do_work(args)
    # This method is called in it's own new thread when you
    # call new worker. args is set to :args
    CGI::Session::ActiveRecordStore::Session.destroy_all( ['updated_at <?', 20.minutes.ago] ) 
    logger.info "[#{Time.now.to_s}] Deleted inactive sessions"
    done_working! # This is required when the job is done!
  end
end
SessionCleanerWorker.register
