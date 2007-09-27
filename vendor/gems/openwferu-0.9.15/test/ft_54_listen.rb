
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'flowtestbase'
require 'openwfe/def'
require 'openwfe/participants/participants'

include OpenWFE


class FlowTest54 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end


    #
    # Test 0
    #

    class Test0 < ProcessDefinition
        concurrence do

            listen :to => "^channel_.$" do
                _print "ok"
            end

            sequence do

                _sleep "500"
                    #
                    # just making sure that the participant is evaluated
                    # after the listen [registration]

                participant :ref => "channel_z"
            end
        end
    end

    #def xxxx_0
    def test_0

        @engine.register_participant :channel_z, NoOperationParticipant

        dotest(Test0, "ok")
    end


    #
    # Test 1
    #

    class Test1 < ProcessDefinition
        concurrence do

            listen :to => "^channel_.$", :where => "${f:f0} == alpha" do
                _print "alpha"
            end

            sequence do

                _sleep "500"
                    #
                    # just making sure that the participant is evaluated
                    # after the listen [registration]

                participant :ref => "channel_z"
                set :field => "f0", :value => "alpha"
                participant :ref => "channel_z"
            end
        end
    end

    #def xxxx_1
    def test_1

        @engine.register_participant :channel_z, NoOperationParticipant

        dotest(Test1, "alpha")
    end


    #
    # Test 2
    #

    class Test2 < ProcessDefinition
        concurrence do

            listen :to => "^channel_.$" do
                #
                # upon apply by default

                _print "apply"
            end
            listen :to => "^channel_.$", :upon => "reply" do
                _print "reply"
            end

            sequence do

                _sleep "500"

                participant :ref => "channel_z"

                participant :ref => "channel_z"
                    #
                    # listeners are 'once' by default, check that
            end
        end
    end

    #def xxxx_2
    def test_2

        @engine.register_participant :channel_z, NoOperationParticipant

        dotest(Test2, "apply\nreply")
    end


    #
    # Test 3
    #

    class Test3 < ProcessDefinition
        concurrence do

            listen :to => "^channel_.$", :once => false do
                _print "apply"
            end

            sequence do
                _sleep "500"
                participant :ref => "channel_z"
                participant :ref => "channel_z"
            end
        end
    end

    #def xxxx_3
    def test_3

        @engine.register_participant :channel_z do
            @tracer << "z\n"
        end

        dotest(Test3, "z\napply\nz\napply", 2, true)
    end


    #
    # Test 4
    #

    class Test4 < ProcessDefinition
        concurrence do

            #listen :to => "^channel_.$", :rwhere => "self.fei.wfid == '${r:workitem.fei.wfid}'" do
            listen :to => "^channel_.$", :where => "${r:fei.wfid} == ${r:workitem.fei.wfid}" do
                _print "ok"
            end

            sequence do
                _sleep "500"
                participant :ref => "channel_z"
            end
        end
    end

    #def xxxx_4
    def test_4

        @engine.register_participant :channel_z do
            @tracer << "z\n"
        end

        dotest(Test4, "z\nok")
    end


    #
    # Test 5
    #

    class Test5 < ProcessDefinition
        concurrence do

            listen :to => :channel_z do
                _print "ok"
            end

            sequence do
                _sleep "500"
                channel_zz
                channel_z
            end
        end
    end

    #def xxxx_5
    def test_5

        @engine.register_participant :channel_z do
            @tracer << "z\n"
        end
        @engine.register_participant :channel_zz do
            @tracer << "zz\n"
        end

        dotest(Test5, "zz\nok\nz")
    end

end

