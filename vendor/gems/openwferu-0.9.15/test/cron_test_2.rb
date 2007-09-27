
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
class CronTest2 < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    def t_0

        $var = 0

        scheduler = OpenWFE::Scheduler.new
        scheduler.start

        scheduler.schedule '* * * * *' do
            $var += 1
        end

        sleep 1
        scheduler.stop

        puts Time.now
        puts "XXX #{$var}" if $var != 0
    end

    def test_0
        300.times do 
            t_0
        end
    end
end
