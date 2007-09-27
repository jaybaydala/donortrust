
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/def'

include OpenWFE


#
# just testing the
#
#     require 'openwfe/def'
#
# shortcut
#

class FlowTest24 < Test::Unit::TestCase
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
            process_definition :name => "ft_24_def", :revision => "0" do
                _print "ok"
            end
        end
    end

    def test_0
        dotest(TestDefinition0, "ok")
    end

end

