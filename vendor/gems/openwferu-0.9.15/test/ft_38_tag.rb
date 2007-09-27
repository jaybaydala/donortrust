
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'openwfe/def'

require 'flowtestbase'


class FlowTest38 < Test::Unit::TestCase
    include FlowTestBase

    #def teardown
    #end

    #def setup
    #end

    #
    # test 0
    #

    class TestTag0 < OpenWFE::ProcessDefinition
        concurrence do
            sequence :tag => "seq0" do
                _sleep "1s"
                _print "hello"
            end
            _undo :ref => "seq0"
            _print "blah"
        end
    end

    def test_tag_0

        log_level_to_debug

        dotest(TestTag0, "blah")
    end


    #
    # test 1
    #

    class TestTag1 < OpenWFE::ProcessDefinition
        concurrence do
            sequence :tag => "seq0" do
                count
                _sleep "1s"
                _print "hello"
            end
            _redo :ref => "seq0"
            _print "blah"
        end
    end

    def xxxx_tag_1
    #def test_tag_1

        count = 0

        @engine.register_participant :count do
            count += 1
        end

        dotest TestTag1, "blah\nhello", 2

        assert_equal count, 1
    end


    #
    # test 2
    #

    class TestTag2 < OpenWFE::ProcessDefinition
        sequence do
            sequence :tag => "seq0" do
                count
                _print "hello"
            end
            _redo :ref => "seq0"
            _print "blah"
        end
    end

    def xxxx_tag_2
    #def test_tag_2

        count = 0

        @engine.register_participant(:count) do
            count += 1
        end

        dotest TestTag2, "hello\nblah", true

        assert_equal count, 1
    end


    #
    # test 3
    #

    class TestTag3 < OpenWFE::ProcessDefinition
        sequence do
            sequence :tag => "seq0" do
                _print "1"
                undo :ref => "seq0"
                _print "2"
            end
            _print "3"
        end
    end

    def xxxx_tag_3
    #def test_tag_3

        dotest TestTag3, "1\n3"
    end

end

