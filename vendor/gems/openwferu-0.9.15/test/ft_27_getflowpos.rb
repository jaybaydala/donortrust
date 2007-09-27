
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'openwfe/def'
require 'openwfe/worklist/storeparticipant'

require 'flowtestbase'


class FlowTest27 < Test::Unit::TestCase
    include FlowTestBase

    #def teardown
    #end

    #def setup
    #end

    #
    # TEST 0

    class TestDefinition0 < ProcessDefinition
        def make
            _process_definition :name => "27_gfp", :revision => "0" do
                _sequence do
                    store_p
                end
            end
        end
    end

    #def xxxx_gfp_0
    def test_gfp_0

        #sp = @engine.register_participant("store_p", OpenWFE::YamlParticipant)
        sp = @engine.register_participant("store_p", OpenWFE::HashParticipant)

        fei = @engine.launch(TestDefinition0)

        sleep 0.100

        l = @engine.get_process_stack(fei.wfid)

        #print_exp_list(l)

        assert_equal \
            l.size, 3, "get_process_stack() returned #{l.size} elements"

        ps = @engine.list_process_status
        #puts
        #puts ps[fei.parent_wfid].to_s
        #puts

        assert_equal ps[fei.parent_wfid].errors.size, 0
        assert_equal ps[fei.parent_wfid].expressions.size, 1
        assert_kind_of ParticipantExpression, ps[fei.parent_wfid].expressions[0]

        ps = @engine.list_process_status fei.wfid[0, 4]

        assert_equal ps[fei.parent_wfid].errors.size, 0
        assert_equal ps[fei.parent_wfid].expressions.size, 1
        assert_kind_of ParticipantExpression, ps[fei.parent_wfid].expressions[0]

        #
        # resume process

        wi = sp.first_workitem

        sp.forward(wi)

        @engine.wait_for fei

        assert_equal sp.size, 0
    end


    #
    # TEST 0b

    class Gfp27b < ProcessDefinition
        sequence do
            store_p
        end
    end

    #def xxxx_gfp_0b
    def test_gfp_0b

        sp = @engine.register_participant("store_p", OpenWFE::YamlParticipant)

        #fei = @engine.launch TestDefinition0
        fei = @engine.launch Gfp27b

        sleep 0.100

        #l = @engine.get_process_stack(fei.wfid)
        l = @engine.get_process_stack(fei)
            #
            # shortcut version

        #print_exp_list l

        assert_equal l.size, 3

        l = @engine.list_processes()
        assert_equal l.size, 1

        l = @engine.list_processes(false, "nada")
        assert_equal l.size, 0

        l = @engine.list_workflows(false, fei.wfid[0, 3])
        assert_equal l.size, 1

        #
        # resume flow and terminate it

        wi = sp.first_workitem

        assert wi

        sp.forward(wi)

        @engine.wait_for fei

        assert_equal sp.size, 0
    end

end

