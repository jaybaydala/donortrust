
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Tue Jan  2 13:14:37 JST 2007
#

require 'flowtestbase'
require 'openwfe/expressions/raw_prog'


class FlowTest10b < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    #
    # Test 0
    #

    class TestDefinition0 < ProcessDefinition
        def make
            process_definition :name => "10b_loop", :revision => "0" do
                _loop do
                    my_participant
                    _print "${f:last_digit}"
                end
            end
        end
    end

    def test_loop_0

        @engine.register_participant("my_participant") do |workitem|

            wfid = workitem.fei.workflow_instance_id
            last_digit = wfid[-1, 1]

            #puts "wfid :       #{wfid}"
            #puts "last_digit : #{last_digit}"

            workitem.last_digit = last_digit

            workitem.__cursor_command__ = "break" if last_digit > "4"
        end

        dotest(
            TestDefinition0,
            """
0
1
2
3
4
            """.strip,
            true)
    end

end

