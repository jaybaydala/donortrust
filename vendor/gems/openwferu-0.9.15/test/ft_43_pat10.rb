
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/def'

include OpenWFE


class FlowTest43 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end


    #
    # Test 0
    #

    class TestCase43a0 < ProcessDefinition
        def initialize (jump)
            super()
            @jump = jump
        end
        def make
            process_definition :name => "jump", :revision => "0" do
                sequence do
                    set :field => "__cursor_command__", :value => "jump #{@jump}"
                    cursor do
                        _print "0"
                        _print "1"
                        _print "2"
                    end
                    _print "3"
                end
            end
        end
    end

    #def xxxx_0
    def test_0
        dotest(
            TestCase43a0.new(1), 
            """
1
2
3
            """.strip)
    end

    #def xxxx_1
    def test_1
        dotest(
            TestCase43a0.new(2), 
            """
2
3
            """.strip)
    end

    #def xxxx_2
    def test_2
        dotest(
            TestCase43a0.new(2000), 
            """
2
3
            """.strip)
    end


    #
    # Test 3
    #

    class TestCase43a3 < ProcessDefinition
        sequence do
            set :field => "__cursor_command__", :value => "jump 2"
            cursor do
                _print "0"
                skip :step => 2
                jump :step => 0
                _print "1"
            end
            _print "2"
        end
    end

    #def xxxx_3
    def test_3
        dotest(
            TestCase43a3,
            """
0
1
2
            """.strip)
    end

end

