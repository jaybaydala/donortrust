
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/expressions/raw_prog'

include OpenWFE



class FlowTest21 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    #
    # Test 0
    #

    class TestDefinition0 < ProcessDefinition
        cron :tab => "* * * * *", :name => "cron" do
            participant :cron_event
        end
    end

    #
    # this one tests whether a cron event is removed when his process
    # terminates, as should be.
    #
    def test_0

        #log_level_to_debug

        @engine.register_participant(:cron_event) do
            @tracer << "cron_event"
        end

        dotest(TestDefinition0, "", 62)
    end

    #
    # Test 1
    #

    class TestDefinition1 < ProcessDefinition
        sequence do
            cron :every => "2s", :name => "cron" do
                participant :cron_event
            end
            _sleep "10s"
        end
    end

    def test_1

        #log_level_to_debug

        @engine.register_participant(:cron_event) do
            @tracer << "."
        end

        dotest(TestDefinition1, [ "....", "....." ])
    end

end

