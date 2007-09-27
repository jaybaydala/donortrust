
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/def'
require 'openwfe/participants/participants'

include OpenWFE


class FlowTest53 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    #
    # Test 0
    #

    class Test0 < ProcessDefinition
        sequence do
            _print "a"
            participant :ref => :null, :timeout => "1s"
            _print "b"
        end
    end

    #def xxxx_0
    def test_0

        @engine.register_participant :null, NullParticipant

        dotest(Test0, "a\nb")
    end


    #
    # Test 1
    #

    class Test1 < ProcessDefinition
        sequence do
            _print "a"
            participant :ref => :noop
            _print "b"
        end
    end

    #def xxxx_1
    def test_1

        @engine.register_participant :noop, NoOperationParticipant

        dotest(Test1, "a\nb")
    end

end

