
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Tue Sep 11 08:48:18 JST 2007
#

require 'openwfe/def'

require 'flowtestbase'


class FlowTest67 < Test::Unit::TestCase
    include FlowTestBase

    #def teardown
    #end

    #def setup
    #end

    #
    # TEST 0

    class Test0 < ProcessDefinition
        _print "hell0"
    end

    def test_0

        #log_level_to_debug

        @engine.launch(Test0, :in => "2s")

        sleep 0.200

        assert_equal @tracer.to_s, ""

        sleep 2.500

        assert_equal @tracer.to_s, "hell0"
    end

    #
    # TEST 1

    #def xxxx_1
    def test_1

        #log_level_to_debug

        t = Time.now

        @engine.launch(Test0, :at => (t + 2).to_s)

        sleep 0.200

        assert_equal @tracer.to_s, ""

        sleep 2.500

        assert_equal @tracer.to_s, "hell0"
    end

    #
    # TEST 2

    #def xxxx_2
    def test_2

        log_level_to_debug

        @engine.launch(Test0, :cron => "* * * * *")

        assert_equal @tracer.to_s, ""

        sleep 130

        assert_equal @tracer.to_s, "hell0\nhell0"
    end

    #
    # TEST 3

    #def xxxx_3
    def test_3

        log_level_to_debug

        @engine.launch(Test0, :every => "2s")

        assert_equal @tracer.to_s, ""

        sleep 5

        assert_equal @tracer.to_s, "hell0\nhell0"
    end

end

