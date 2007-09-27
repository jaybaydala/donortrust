
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/def'

include OpenWFE


class FlowTest44b < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end


    #
    # Test 0
    #

    class TestCase44b0 < ProcessDefinition
        sequence do
            set :field => "f", :value => "v"
            save :to_field => "saved"
            #pp_workitem
            _print "${f:saved.f}"
            restore :from_field => "saved"
            _print "${f:saved.f}"
            _print "${f:f}"
        end
    end

    #def xxxx_0
    def test_0
        dotest(
            TestCase44b0,
            """
v

v
            """.strip)
    end


    #
    # Test 1
    #

    class TestCase44b1 < ProcessDefinition
        sequence do
            set :field => "f", :value => "field_value"
            save :to_variable => "v"
            #pp_workitem
            set :field => "f", :value => "field_value_x"
            _print "${f:f}"
            restore :from_variable => "v"
            _print "${f:f}"
        end
    end

    #def xxxx_1
    def test_1
        dotest(
            TestCase44b1,
            """
field_value_x
field_value
            """.strip)
    end


    #
    # Test 2
    #

    class TestCase44b2 < ProcessDefinition
        sequence do
            set :field => "f", :value => "field_value"
            save :to_variable => "v"
            restore :from_variable => :v, :to_field => :f1
            #pp_workitem
            _print "${f:f1.f}"
        end
    end

    #def xxxx_2
    def test_2
        dotest(
            TestCase44b2,
            """
field_value
            """.strip)
    end


    #
    # Test 3
    #

    class TestCase44b3 < ProcessDefinition
        sequence do
            set :field => "f0", :value => "value_a"
            save :to_variable => "v"
            set :field => "f0", :value => "value_aa"
            set :field => "f1", :value => "value_b"
            restore :from_variable => :v, :merge_lead => :current
            #pp_workitem
            _print "${f:f0}"
            _print "${f:f1}"
        end
    end

    #def xxxx_3
    def test_3
        dotest(
            TestCase44b3,
            """
value_aa
value_b
            """.strip)
    end


    #
    # Test 4
    #

    class TestCase44b4 < ProcessDefinition
        sequence do
            set :field => "f0", :value => "value_a"
            save :to_variable => "v"
            set :field => "f0", :value => "value_aa"
            set :field => "f1", :value => "value_b"
            restore :from_variable => :v, :merge_lead => :restored
            #pp_workitem
            _print "${f:f0}"
            _print "${f:f1}"
        end
    end

    #def xxxx_4
    def test_4
        dotest(
            TestCase44b4,
            """
value_a
value_b
            """.strip)
    end

end

