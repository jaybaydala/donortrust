
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/def'

include OpenWFE



class FlowTest39b < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    #
    # Test 0
    #

    class TestReserve39b0 < ProcessDefinition
        #
        # doesn't prove it enough though...
        #
        concurrence do
            reserve :mutex => :toto, :frequency => "500" do
                sequence do
                    test_alpha
                    test_bravo
                end
            end
            reserve :mutex => :toto, :frequency => "500" do
                sequence do
                    test_charly
                    test_delta
                end
            end
        end
    end

    def test_2

        dotest(
            TestReserve39b0, 
            [
"""
test-charly
test-delta
test-alpha
test-bravo
""".strip, 
"""
test-alpha
test-bravo
test-charly
test-delta
""".strip 
            ],
            3)
    end

end

