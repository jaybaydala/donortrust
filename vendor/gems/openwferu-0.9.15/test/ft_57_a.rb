
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'pending'
require 'openwfe/def'
#require 'openwfe/participants/participants'

include OpenWFE


class FlowTest57 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end


    #
    # Test 0
    #

    class Test0 < ProcessDefinition
        sequence do
            _set :field => "list" do
                _a """
                    <list>
                        <string>a</string>
                        <string>b</string>
                        <string>c</string>
                    </list>
                """
            end
            _print "${r:wi.list.join('|')}"
            _print "-"
            _set :field => "list" do
                _attribute """
--- 
- a
- b
- 3
                """
            end
            _print "${r:wi.list.join('|')}"
        end
    end

    #def xxxx_0
    def test_0
        dotest(
            Test0, 
            """
a|b|c
-
a|b|3
            """.strip)
    end

    #def xxxx_1
    def test_1
        dotest(
            """
<process-definition name='57_a' revision='1'>
    <sequence>
        <set field='list'>
            <a>
--- 
- c
- d
- e
            </a>
        </set>
        <print>${r:wi.list.join('|')}</print>
    </sequence>
</process-definition>
            """.strip,
            "c|d|e")
    end

    #def xxxx_2
    def test_2
        dotest(
            """
<process-definition name='57_a' revision='2'>
    <sequence>
        <set field='list'>
            <a>
            <list>
                <string>a</string>
                <string>2</string>
                <string>c</string>
            </list>
            </a>
        </set>
        <print>${r:wi.list.join('|')}</print>
    </sequence>
</process-definition>
            """.strip,
            "a|2|c")
    end

    #
    # Test 3
    #

    class Test3 < ProcessDefinition
        sequence do
            _set :field => "other" do
                reval { "77" }
            end
            _print "${f:other}"
        end
    end

    def test_3
        dotest(Test3, "77")
    end
end

