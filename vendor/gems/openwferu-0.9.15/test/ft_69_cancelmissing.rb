
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Thu Sep 13 09:50:29 JST 2007
#

require 'openwfe/def'

require 'flowtestbase'


class FlowTest69 < Test::Unit::TestCase
    include FlowTestBase

    #def teardown
    #end

    #def setup
    #end

    #
    # TEST 0

    class Test0 < ProcessDefinition
        #__bravo
        participant :ref => "__bravo"
    end

    def test_0

        #log_level_to_debug

        fei = @engine.launch(Test0)

        sleep 0.200

        assert @engine.process_status(fei.wfid).errors.size > 0

        @engine.cancel_process fei

        assert_nil @engine.process_status(fei.wfid)
        assert_equal @engine.list_process_status, {}
    end

end

