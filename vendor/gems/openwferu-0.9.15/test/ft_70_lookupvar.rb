
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Thu Sep 13 17:46:20 JST 2007
#

require 'openwfe/def'

require 'flowtestbase'


class FlowTest70 < Test::Unit::TestCase
    include FlowTestBase

    #def teardown
    #end

    #def setup
    #end

    #
    # TEST 0

    class Test0 < ProcessDefinition
        sequence do
            set :v => "//topvar", :val => "top"
            set :v => "localvar", :val => "local"
            toto
        end
    end

    def test_0

        #log_level_to_debug

        @engine.register_participant "toto", NullParticipant

        fei = @engine.launch(Test0)

        sleep 0.100

        assert_equal @engine.lookup_variable("topvar"), "top"
        assert_equal @engine.lookup_variable("topvar", fei.wfid), "top"
        assert_equal @engine.lookup_variable("localvar", fei.wfid), "local"

        @engine.cancel_process(fei.wfid)

        sleep 0.100
    end

end

