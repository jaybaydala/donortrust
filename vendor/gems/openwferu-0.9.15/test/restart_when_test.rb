#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Sun Oct 29 15:41:44 JST 2006
#
# somewhere between Philippina and the Japan
#

require 'test/unit'

require 'openwfe/workitem'
require 'openwfe/engine/file_persisted_engine'
require 'openwfe/expressions/raw_prog'

require 'rutest_utils'

include OpenWFE


class RestartWhenTest < Test::Unit::TestCase

    #def setup
    #    @engine = $WORKFLOW_ENGINE_CLASS.new()
    #end

    #def teardown
    #end

    class RestartWhenDefinition0 < ProcessDefinition
        def make
            concurrence do
                _when :test => "${v:done} == true", :frequency => "1s" do
                #_when :test => "${v:done} == true" do
                    _print "when triggered"
                end
                sequence do
                    _sleep "2s"
                    _set :variable => "done", :value => "true"
                    _print "done"
                end
            end
        end
    end

    def test_restart_0
        dotest FilePersistedEngine
    end

    def test_restart_1
        dotest CachedFilePersistedEngine
    end

    protected

        def dotest (engine_class)

            engine = new_engine(engine_class)

            li = LaunchItem.new(RestartWhenDefinition0)

            engine.launch(li)

            sleep(1)

            engine.stop()

            $OWFE_LOG.warn "stopped the engine"

            old_engine = engine
            engine = new_engine(engine_class)

            $OWFE_LOG.warn "started the new engine"

            sleep(3)

            s_old = old_engine.application_context["__tracer"].to_s
            s_now = engine.application_context["__tracer"].to_s

            #uts "__ s_old >>>#{s_old}<<<"
            #uts "__ s_now >>>#{s_now}<<<"

            assert \
                (s_old == "" and s_now == "done\nwhen triggered"), 
                "old : '#{s_old}'  /  new : '#{s_now}'  BAD for #{engine_class}"

            engine.stop
        end

        def new_engine (engine_class)

            engine = engine_class.new()

            tracer = Tracer.new
            engine.application_context["__tracer"] = tracer

            #engine.reschedule
            engine.reload

            engine
        end

end

