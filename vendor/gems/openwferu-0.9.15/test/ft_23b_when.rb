
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/expressions/raw_prog'

include OpenWFE



class FlowTest23b < Test::Unit::TestCase
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
            process_definition :name => "23b_when0", :revision => "0" do
                concurrence do
                    _when :test => "false == true", :timeout => "3s" do
                        _print "la vaca vuela"
                    end
                    _print "ok"
                end
            end
        end
    end

    def test_0
        dotest(TestDefinition0, "ok", 5)
    end


    #
    # Test 1
    #

    class TestWait23b1 < ProcessDefinition
        concurrence do
            _when :test => "true == true" do
            end
            _print "ok"
        end
    end

    def test_1
        dotest(TestWait23b1, "ok", true)
    end

end

