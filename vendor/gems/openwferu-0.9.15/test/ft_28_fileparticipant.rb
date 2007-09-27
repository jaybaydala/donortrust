
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'find'
require 'fileutils'

require 'openwfe/def'
require 'openwfe/listeners/listeners'
require 'openwfe/participants/participants'

require 'flowtestbase'


class FlowTest28 < Test::Unit::TestCase
    include FlowTestBase

    #def teardown
    #end

    #def setup
    #end

    #
    # TEST 0

    class TestDefinition0 < ProcessDefinition
        def make
            _sequence do
                _participant :fp
                _print "done"
            end
        end
    end

    #def xxxx_fp_0
    def test_fp_0

        FileUtils.mkdir("./work/in") unless File.exist? "./work/in"

        @engine.register_participant("fp", OpenWFE::FileParticipant)
        @engine.add_workitem_listener(OpenWFE::FileListener, "500")

        fei = @engine.launch(TestDefinition0)

        sleep 0.1

        Find.find("./work/out/") do |path|
            next unless path.match ".*\.yaml$"
            FileUtils.mv(path, "./work/in/")
        end

        sleep 2

        assert_equal \
            engine.get_expression_storage.size, 1
    end

end

