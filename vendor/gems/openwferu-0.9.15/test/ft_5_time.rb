
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'flowtestbase'


class FlowTest5 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    def test_sleep_0
    #def xxxx_sleep_0
        dotest(
'''<process-definition name="sleep_0" revision="0">
    <sequence>
        <sleep for="2s" />
        <print>alpha</print>
    </sequence>
</process-definition>''', 
            "alpha", 
            true)
    end

    def test_sleep_1
    #def xxxx_sleep_1
        dotest(
'''<process-definition name="sleep_1" revision="0">
    <concurrence>
        <sequence>
            <sleep for="2s" />
            <print>alpha</print>
        </sequence>
        <print>bravo</print>
    </concurrence>
</process-definition>''', 
            """bravo
alpha""", 
            true)
    end

    def test_sleep_2
    #def xxxx_sleep_2
        dotest(
'''<process-definition name="sleep_2" revision="0">
    <sequence>
        <sleep until="${ruby:Time.new() + 4}" />
        <print>alpha</print>
    </sequence>
</process-definition>''', 
            "alpha", 
            true)
    end

    def test_sleep_3
    #def xxxx_sleep_3
        dotest(
'''<process-definition name="sleep_3" revision="0">
    <sequence>
        <sleep for="900" />
        <print>alpha</print>
    </sequence>
</process-definition>''', "alpha", true)
    end

end

