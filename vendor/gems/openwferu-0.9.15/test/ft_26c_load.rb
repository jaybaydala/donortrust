
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Tue Jan  2 13:14:37 JST 2007
#

#require 'profile'

require 'flowtestbase'
require 'openwfe/expressions/raw_prog'

include OpenWFE


class FlowTest26c < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    #
    # Test 0
    #

    N = 10000

    class TestDefinition0 < ProcessDefinition
        sequence do
            N.times do
                count
            end
        end
    end

    #def xxxx_load_0
    def test_load_0

        #@engine.get_scheduler.sstop
            #
            # JRuby is no friend of the Scheduler

        $count = 0

        @engine.register_participant("count") do |workitem|
            $count += 1
            print "."
        end

        fei = @engine.launch(LaunchItem.new(TestDefinition0))
        puts "launched #{fei}"

        @engine.wait_for fei
        #sleep 60

        assert_equal $count, N
    end

    #
    # Thu Sep 13 15:41:20 JST 2007
    #
    # ruby 1.8.5 (2006-12-25 patchlevel 12) [i686-darwin8.8.3]
    #
    # 10_000 in 27.69s
    #
    # before optimization : 10k in 138.341
    #
    #
    # ruby 1.8.5 (2007-09-13 rev 3876) [i386-jruby1.1]
    #
    # 10_000 in 53.96s
    #
    # ruby 1.8.5 (2007-09-13 rev 3876) [i386-jruby1.1]
    # -O -J-server
    #
    # 10_000 in 42.616s

end

