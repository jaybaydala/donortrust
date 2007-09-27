
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Jul  9 10:25:18 JST 2007
#

require 'openwfe/def'
require 'flowtestbase'


class FlowTest60 < Test::Unit::TestCase
    include FlowTestBase

    #def teardown
    #end

    #def setup
    #end

    #
    # TEST 0

    class TestDefinition0 < ProcessDefinition
        sequence do
            _print "a"
            sequence do
                _print "b.0"
                _sleep "1s"
                _print "b.1"
            end
            _print "c"
        end
    end

    def test_0

        #$OWFE_LOG.level = Logger::DEBUG

        fei = @engine.launch TestDefinition0

        sleep 0.200

        #puts
        #puts @engine.get_process_stack fei.wfid
        #puts

        fei.expression_id = "0.0.1"
        fei.expression_name = "sequence"
        @engine.cancel_expression fei

        sleep 0.200

        assert_equal @tracer.to_s, "a\nb.0\nc"

        assert_equal @engine.get_process_stack(fei.wfid).size, 0

        #$OWFE_LOG.level = Logger::INFO
    end

    def test_1

        #$OWFE_LOG.level = Logger::DEBUG

        fei = @engine.launch TestDefinition0

        sleep 0.200

        fei.expression_id = "0.0.1.2"
        fei.expression_name = "print"
        @engine.cancel_expression fei

        @engine.wait_for(fei.wfid)

        assert_equal @tracer.to_s, "a\nb.0\nc"

        assert_equal @engine.get_process_stack(fei.wfid).size, 0

        #$OWFE_LOG.level = Logger::INFO
    end

end

