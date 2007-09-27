
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Tue Jan  2 13:14:37 JST 2007
#

require 'flowtestbase'
require 'openwfe/def'

include OpenWFE


class FlowTest11b < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    #
    # Test 0
    #
    # bug #9905 : "NPE" was raised...
    #

    class TestDefinition0 < ProcessDefinition
        def make
            _print "ok"
        end
    end

    #def xxxx_0
    def test_0
        dotest(
            TestDefinition0.new,
            "ok")
    end

end

