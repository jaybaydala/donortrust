#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Sun Oct 29 15:41:44 JST 2006
#

require 'test/unit'

require 'openwfe/workitem'
require 'openwfe/engine/file_persisted_engine'
require 'openwfe/expressions/raw_prog'

require 'rutest_utils'

include OpenWFE


class RestartCronTest < Test::Unit::TestCase

    #def setup
    #    @engine = $WORKFLOW_ENGINE_CLASS.new()
    #end

    #def teardown
    #end

    class RestartDefinition0 < ProcessDefinition
        def make
            process_definition :name => "rs0", :revision => "0" do
                cron :tab => "* * * * *", :name => "//cron" do
                    participant :cron_event_restart
                end
            end
        end
    end

    def test_restart_0

        engine = FilePersistedEngine.new

        count = 0

        participant = lambda do
            #puts "______________________ :cron_event_restart"
            count = count + 1
        end

        engine.register_participant(:cron_event_restart, &participant)

        engine.launch(RestartDefinition0)

        sleep(60)

        engine.stop()

        #puts "___restarting to new engine"

        old_engine = engine
        engine = FilePersistedEngine.new

        engine.register_participant(:cron_event_restart, &participant)

        engine.reload
            #
            # very important

        sleep(60)

        engine.stop()

        #puts "_count : #{count}"

        assert \
            count == 2,
            "the cron expression should have counted to 2, "+
            "but it counted to #{count}"
    end

end

