
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'pending'
require 'openwfe/def'
#require 'openwfe/participants/participants'

include OpenWFE


class FlowTest56 < Test::Unit::TestCase
    include FlowTestBase
    include PendingJobsMixin

    #def setup
    #end

    #def teardown
    #end


    #
    # Test 0
    #

    class Test0 < ProcessDefinition
        sequence do
            _timeout :after => "1s" do
                sequence do
                    _print "ok"
                    _sleep "2s"
                    _print "not ok"
                end
            end
            _print "done"
        end
    end

    #def xxxx_0
    def test_0

        assert_no_jobs_left

        dotest Test0, "ok\ndone"

        assert_no_jobs_left
    end

end

