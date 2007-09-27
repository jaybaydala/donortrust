
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/def'

include OpenWFE


class FlowTest65 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end


    #
    # Test 0
    #

    TEST0 = """
    class Test0 < ProcessDefinition
        _print 'ok.'
    end
    """.strip

    #def xxxx_0
    def test_0
        @engine.launch(TEST0)
        sleep 0.200
        assert_equal @tracer.to_s, "ok."
    end


    #
    # Test 1
    #

    TEST1 = """
<process-definition name='65_1' revision='0.1'>
    <print>ok.</print>
</process-definition>
    """.strip

    #def xxxx_1
    def test_1

        @engine.launch(TEST1)
        sleep 0.200
        assert_equal @tracer.to_s, "ok."
    end

end

