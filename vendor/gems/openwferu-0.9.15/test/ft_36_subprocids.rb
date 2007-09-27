
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'openwfe/def'

require 'flowtestbase'


class FlowTest36 < Test::Unit::TestCase
    include FlowTestBase

    #def teardown
    #end

    #def setup
    #end

    #
    # TEST 0

    class TestSubProcId0 < ProcessDefinition
        concurrence do
            subproc
            subproc
        end
        process_definition :name => :subproc do
            sequence do
                #reval "puts fei"
                check
            end
        end
    end

    class TestSubProcId1 < ProcessDefinition
        concurrence do
            subprocess :ref => "subproc"
            subprocess :ref => :subproc
        end
        process_definition :name => :subproc do
            sequence do
                #reval "puts fei"
                check
            end
        end
    end

    def test_subprocid_0

        feis = {}

        @engine.register_participant(:check) do |fexp, wi|
            #puts fexp.fei.to_debug_s
            feis[fexp.fei] = true
        end

        @engine.launch(TestSubProcId0)
        @engine.launch(TestSubProcId1)

        sleep 1

        assert_equal feis.keys.size, 4
    end


    #
    # TEST about Iterator

    class TestIteratorSubId0 < ProcessDefinition
        iterator :on_value => "a, b", :to_variable => "v" do
            check
        end
    end

    def test_iterator_subid_0

        feis = {}

        @engine.register_participant(:check) do |fexp, wi|
            #puts fexp.fei.to_debug_s
            feis[fexp.fei] = true
        end

        @engine.launch(TestIteratorSubId0)

        sleep 0.250

        assert_equal feis.keys.size, 2
    end

end

