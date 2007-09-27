
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Sun Oct 29 16:18:25 JST 2006
#

require 'test/unit'

require 'openwfe/util/otime'
require 'openwfe/util/scheduler'


#
# testing otime and the scheduler (its cron aspect)
#
class CronTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    def test_cron_0

        $var = 0

        scheduler = OpenWFE::Scheduler.new
        scheduler.start

        sid = scheduler.schedule(
            '* * * * *',
            :schedulable => CounterSchedulable.new)

        assert sid, "scheduler did not return a job id"

        sleep 120
        scheduler.stop

        #puts ">#{$var}<"

        assert_equal $var, 2, "$var should be at 2, it's at #{$var}"
    end

    protected

        class CounterSchedulable
            include OpenWFE::Schedulable

            def trigger (params)
                $var = $var + 1
            end
        end

end
