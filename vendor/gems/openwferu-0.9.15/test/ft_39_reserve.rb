
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/def'

include OpenWFE



class FlowTest39 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end


    #
    # Test 0
    #

    class TestReserve39a0 < ProcessDefinition
        reserve :mutex => :toto do
            _print "ok"
        end
    end

    def test_0
        dotest(TestReserve39a0, "ok", true)
    end


    #
    # Test 1
    #

    class TestReserve39a1 < ProcessDefinition
        sequence do
            reserve :mutex => :toto do
                _print "${r:'${toto}' != ''}"
            end
            _print "${r:'${toto}' == ''}"
            _print "over."
        end
    end

    def test_1
        dotest(TestReserve39a1, "true\ntrue\nover.", true)
    end


    #
    # Test 2
    #

    # moved to ft_39b_reserve.rb

    #
    # Test 3
    #

    class TestReserve39a3 < ProcessDefinition
        reserve :mutex => :toto do
        end
    end

    def test_3
        dotest(TestReserve39a3, "", true)
    end

end

