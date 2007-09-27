
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/def'

include OpenWFE



class FlowTest23c < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    #
    # Test 0
    #

    class Wait0c < ProcessDefinition
        sequence do
            concurrence do
                sequence do
                    wait :until => "${done} == true", :frequency => "2s"
                    _print "after wait"
                end
                sequence do
                    _sleep "1s"
                    _print "before done"
                    _set :variable => "done", :value => "true"
                end
            end
            _print "over"
        end
    end

    def test_0
        dotest(
            Wait0c, 
            """
before done
after wait
over
            """.strip, 
            3)
    end

    #
    # Test 1
    #

    class Wait1c < ProcessDefinition
        sequence do
            concurrence do
                sequence do
                    wait :frequency => "2s" do
                        equals :variable_value => "done", :other_value => "true"
                    end
                    _print "after when"
                end
                sequence do
                    _sleep "1s"
                    _print "before done"
                    _set :variable => "done", :value => "true"
                end
            end
            _print "over"
        end
    end

    def test_1
        dotest(
            Wait1c, 
            """
before done
after when
over
            """.strip, 
            4)
    end

end

