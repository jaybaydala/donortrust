
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Dec 11 09:49:18 JST 2006
# Narita terminal 1
#

require 'flowtestbase'


class FlowTest6 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    def test_lambda_0

        dotest(
'''<process-definition name="lambda_0" revision="0">
    <sequence>
        <set variable="inside1">
            <process-definition>
                <print>bonjour ${name}</print>
            </process-definition>
        </set>

        <inside1 name="world" />
        <print>over</print>
    </sequence>
</process-definition>''', """bonjour world
over""")
    end

    #
    # TEST 1

    class Test1 < OpenWFE::ProcessDefinition
        sequence do
            _set :v => "inside1" do
                process_definition do
                    _print "hello ${name}"
                end
            end
            inside1 :name => "mundo"
            _print "done."
        end
    end

    def test_1

        dotest(Test1, "hello mundo\ndone.")
    end

end

