
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/expressions/raw_prog'

include OpenWFE



class FlowTest20 < Test::Unit::TestCase
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
            process_definition :name => "rs0", :revision => "0" do
                concurrence do
                    cron :tab => "* * * * *", :name => "cron" do
                        participant :cron_event
                    end
                    sequence do
                        _print "before"
                        _sleep :for => "61s"
                        _print "after"
                    end
                end
            end
        end
    end

    def test_0

        @engine.register_participant(:cron_event) do |fexp, wi|
            @tracer << "#{fexp.class.name}\n"
        end

        dotest(
            TestDefinition0, 
            """before
OpenWFE::ParticipantExpression
after""", 
            62)
    end

end

