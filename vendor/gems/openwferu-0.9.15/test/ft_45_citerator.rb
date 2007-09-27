
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/def'

include OpenWFE


class FlowTest45 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end


    #
    # Test 0
    #

    class TestCase45a0 < ProcessDefinition
        sequence do
            concurrent_iterator :on_value => "1, 2", :to_variable => "v" do
                _print "${r:fei.sub_instance_id} - ${v}"
            end
            _print "done."
        end
    end

    #def xxxx_0
    def test_0
        dotest(
            TestCase45a0,
            [ """
.0 - 1
.1 - 2
done.
              """.strip,
              """
.1 - 2
.0 - 1
done.
              """.strip
            ])
    end


    #
    # Test 1
    #

    class TestCase45a1 < ProcessDefinition
        sequence do
            concurrent_iterator :on_value => "1, 2", :to_field => "f" do
                _print "${r:fei.sub_instance_id} - ${f:f}"
            end
            _print "done."
        end
    end

    #def xxxx_1
    def test_1
        dotest(
            TestCase45a1,
            [ """
.0 - 1
.1 - 2
done.
              """.strip,
              """
.1 - 2
.0 - 1
done.
              """.strip
            ])
    end

    #
    # Test 2
    #

    class TestCase45a2 < ProcessDefinition
        sequence do
            concurrent_iterator \
                :on_value => "1, 2", 
                :to_field => "f",
                :over_if => "${f:__ip__} == 0" do

                _print "${r:fei.sub_instance_id} - ${f:f}"
            end
            _print "done."
        end
    end

    # test 'parked' for now

    def xxxx_2
    #def test_2
        dotest(
            TestCase45a2,
            """
.0 - 1
.1 - 2
done.
            """.strip)
    end


    #
    # Test 3
    #

    class TestCase45a3 < ProcessDefinition
        sequence do
            concurrent_iterator :on_value => "", :to_field => "f" do
                _print "${r:fei.sub_instance_id} - ${f:f}"
            end
            _print "done."
        end
    end

    # test 'parked' for now

    #def xxxx_3
    def test_3
        dotest(
            TestCase45a3,
            """
done.
            """.strip)
    end

end

