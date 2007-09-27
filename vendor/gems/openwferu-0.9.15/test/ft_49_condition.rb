
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/def'

include OpenWFE


class FlowTest49 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end


    #
    # Test 0
    #

    class TestCondition49a0 < ProcessDefinition
        sequence do
            _if :test => "false"
            _print "0 ${f:__result__}"
            _if :test => "true; false"
            _print "1 ${f:__result__}"
            _if :test => "false; true"
            _print "2 ${f:__result__}"
            _if :test => "print ''; true"
            _print "3 ${f:__result__}"
            _if :test => "begin print ''; end; true"
            _print "4 ${f:__result__}"

            _if :test => "true == "
            _print "5 ${f:__result__}"
            _if :test => " == true"
            _print "6 ${f:__result__}"
        end
    end

    #def xxxx_0
    def test_0

        dotest(
            TestCondition49a0,
            """
0 
1 
2 true
3 true
4 true
5 
6 
            """.strip)
    end


    #
    # Test 1
    #

    class TestCondition49a1 < ProcessDefinition
        sequence do
            _if :test => "true and false and false"
            _print "0 ${f:__result__}"
            _if :rtest => "true and true and true"
            _print "1 ${f:__result__}"
            _if :rtest => "false or false or true"
            _print "2 ${f:__result__}"
        end
    end

    #def xxxx_0
    def test_1

        dotest(
            TestCondition49a1,
            """
0 
1 true
2 true
            """.strip)
    end


    #
    # Test 2
    #

    class TestCondition49a2 < ProcessDefinition
        sequence do
            _if :test => "true"
            _print "0 ${f:__result__}"
            _if :not => "false"
            _print "1 ${f:__result__}"
            _if :rnot => "1 > 3"
            _print "2 ${f:__result__}"
            _if :rnot => "1 > -1"
            _print "3 ${f:__result__}"
            _if :rtest => "workitem.attributes.size % 2 == 0"
            _print "4 ${f:__result__}"
            _if :rtest => "wi.attributes.size % 2 == 1"
            _print "5 ${f:__result__}"
        end
    end

    #def xxxx_2
    def test_2

        dotest(
            TestCondition49a2,
            """
0 true
1 true
2 true
3 
4 
5 true
            """.strip)
    end

end

