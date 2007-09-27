
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Sat Jul  7 22:44:00 JST 2007 (tanabata)
#

require 'openwfe/def'
require 'openwfe/worklist/storeparticipant'

require 'flowtestbase'


class FlowTest59 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    #
    # TEST 0

    class Def59 < ProcessDefinition
        concurrence do
            store_a
            store_b
        end
    end

    #def xxxx_0
    def test_0

        sa = @engine.register_participant("store_a", OpenWFE::HashParticipant)
        sb = @engine.register_participant("store_b", OpenWFE::HashParticipant)

        fei = @engine.launch Def59

        sleep 0.250

        ps = @engine.list_process_status
        #puts ps

        assert_equal ps[fei.wfid].expressions.size, 2
        assert_equal ps[fei.wfid].errors.size, 0

        @engine.cancel_process fei
    end

    #
    # TEST 0b

    class Def59b < ProcessDefinition
        sequence do
            alpha
            bravo
        end
    end

    #def xxxx_0b
    def test_0b

        a = @engine.register_participant(:alpha, OpenWFE::HashParticipant)
        b = @engine.register_participant(:bravo, OpenWFE::HashParticipant)

        fei = @engine.launch Def59b

        sleep 0.100

        ps = @engine.list_process_status
        #puts ps

        assert_equal ps[fei.wfid].expressions.size, 1
        assert_equal ps[fei.wfid].errors.size, 0

        @engine.cancel_process fei
    end

    #
    # TEST 1

    class Def59_1 < ProcessDefinition
        sequence do
            nada59_1
            alpha
        end
    end

    #def xxxx_1
    def test_1

        alpha = @engine.register_participant :alpha do
            # nothing
        end

        fei = @engine.launch Def59_1

        sleep 0.200

        ps = @engine.list_process_status
        #puts ps
        #puts ps[fei.wfid].errors

        assert_equal ps[fei.wfid].expressions.size, 1
        assert_equal ps[fei.wfid].errors.size, 1

        #puts
        #puts ps.to_s

        @engine.cancel_process fei.wfid
    end

end

