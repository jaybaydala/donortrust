
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/def'

include OpenWFE


class FlowTest46 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end


    #
    # Test 0
    #

    class TestPTask46a0 < ProcessDefinition
        sequence do

            participant :ref => :nemo, :description => "clean the desk"

            _print "${f:description}"
                # just checking that the description is wiped after usage

            participant :ref => :nemo, :task => "force"

            _print "${f:task}"
        end
    end

    #def xxxx_0
    def test_0

        @engine.register_participant :nemo do |workitem|
            @tracer.puts workitem.params['ref']
            @tracer.puts workitem.params['description']
            @tracer.puts workitem.params['task']
        end

        dotest(
            TestPTask46a0,
            """
nemo
clean the desk


nemo

force
            """.strip)
    end

end

