
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Tue Jan  2 13:14:37 JST 2007
#

require 'flowtestbase'
require 'openwfe/expressions/raw_prog'

include OpenWFE


class FlowTest18 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    #
    # Test 0
    #

    class TestDefinition0 < ProcessDefinition
        def make
            _process_definition :name => "test0", :revision => "0" do
                p_toto
            end
        end
    end

    def test_0
    #def xxxx__0

        dotest(
            TestDefinition0,
            "toto")
    end


    #
    # Test 1
    #

    def test_1
    #def xxxx_1

        dotest(\
"""<process-definition name='test1' revision='0'>
    <p-toto/>
</process-definition>""", "toto")
    end

end

