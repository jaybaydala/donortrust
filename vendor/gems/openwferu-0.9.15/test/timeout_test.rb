#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Sun Oct 29 15:41:44 JST 2006
#

require 'test/unit'

#require 'openwfe/workitem'
require 'openwfe/engine/engine'
require 'openwfe/expressions/raw_prog'
require 'openwfe/worklist/storeparticipant'

require 'rutest_utils'

include OpenWFE


class TimeoutTest < Test::Unit::TestCase

    #def setup
    #    @engine = $WORKFLOW_ENGINE_CLASS.new()
    #end

    #def teardown
    #end

    class TimeoutDefinition0 < ProcessDefinition
        def make
            process_definition :name => "to0", :revision => "0" do
                sequence do
                    participant :ref => "albert", :timeout => "500"
                    _print "timedout? ${f:__timed_out__}"
                    _print "over ${f:done}"
                end
            end
        end
    end

    def test_timeout_0

        albert = HashParticipant.new

        engine = Engine.new

        engine.application_context["__tracer"] = Tracer.new

        engine.register_participant(:albert, albert)

        li = LaunchItem.new(TimeoutDefinition0)

        engine.launch(li)

        sleep(2)

        s = engine.application_context["__tracer"].to_s

        engine.stop

        #puts "trace is >#{s}<"
        #puts "albert.size is #{albert.size}"

        assert \
            albert.size == 0,
            "workitem was not removed from workitem store"
        assert \
            s == """timedout? true
over""",
            "flow did not reach 'over'"
    end

    def test_timeout_1

        albert = HashParticipant.new

        engine = Engine.new

        engine.application_context["__tracer"] = Tracer.new

        engine.register_participant(:albert, albert)

        pjc = engine.get_scheduler.pending_job_count
        assert \
            pjc == 0,
            "0 pending_jobs_count is at #{pjc}, it should be at 0"

        li = LaunchItem.new(TimeoutDefinition0)

        engine.launch(li)

        sleep 0.300

        wi = albert.list_workitems(nil)[0]
        wi.done = "ok"
        albert.proceed(wi)

        sleep 0.300

        s = engine.application_context["__tracer"].to_s

        #puts "trace is >#{s}<"
        #puts "albert.size is #{albert.size}"

        # in this test, the participant doesn't time out

        assert_equal \
            albert.size, 0,
            "workitem was not removed from workitem store"
        assert \
            s == "timedout? \nover ok",
            "flow did not reach 'over ok'"

        pjc = engine.get_scheduler.pending_job_count

        assert \
            pjc == 0,
            "1 pending_jobs_count is at #{pjc}, it should be at 0"
    end

end

