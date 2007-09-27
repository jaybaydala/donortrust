
#
# a method for checking the number of pending jobs left in the engine
#

require 'openwfe/engine/file_persisted_engine'


module PendingJobsMixin

    def assert_no_jobs_left

        min_jobs = if @engine.is_a?(OpenWFE::CachedFilePersistedEngine)
            1
        #elsif @engine.is_a?(OpenWFE::FilePersistedEngine)
        #    0
        else
            0
        end

        assert_equal @engine.get_scheduler.pending_job_count, min_jobs
    end
end

