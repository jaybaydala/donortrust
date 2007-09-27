
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Fri Jun 29 23:12:53 JST 2007
#

require 'openwfe/def'

require 'flowtestbase'

require 'openwfe/engine/file_persisted_engine'
require 'openwfe/expool/errorjournal'



class FlowTest58 < Test::Unit::TestCase
    include FlowTestBase

    #def teardown
    #end

    #def setup
    #end


    #
    # TEST 0

    class Test0 < ProcessDefinition
        sequence do
            participant :alpha
            participant :nada
            participant :bravo
        end
    end

    #def xxxx_0
    def test_0

        ejournal = @engine.get_error_journal

        @engine.register_participant(:alpha) do |wi|
            @tracer << "alpha\n"
        end

        #fei = dotest(Test0, "alpha", 0.500, true)
        li = LaunchItem.new Test0
        fei = @engine.launch li

        sleep 0.200

        assert File.exist?("work/ejournal/#{fei.parent_wfid}.ejournal") \
            if @engine.is_a?(FilePersistedEngine)

        errors = ejournal.get_error_log fei

        #require 'pp'; pp ejournal

        assert_equal errors.length, 1

        first_error = errors[0]

        assert ejournal.has_errors?(fei)
        assert ejournal.has_errors?(fei.wfid)

        # let's look at how errors do stack

        ejournal.replay_at_last_error fei.wfid

        sleep 0.200

        errors = ejournal.get_error_log fei

        assert_equal errors.length, 2

        second_error = errors[1]

        assert second_error.date > first_error.date

        # let's clean the log (we have the error as 'second_error')

        ejournal.remove_error_log fei.wfid

        errors = ejournal.get_error_log fei

        assert_equal errors.length, 0
        assert ( ! ejournal.has_errors?(fei))

        # OK, let's fix the root and replay

        @engine.register_participant(:nada) do |wi|
            @tracer << "nada\n"
        end
        @engine.register_participant(:bravo) do |wi|
            @tracer << "bravo\n"
        end

        # fix done

        assert_equal @tracer.to_s, "alpha"

        ejournal.replay_at_error second_error

        sleep 0.200

        assert_equal @tracer.to_s, "alpha\nnada\nbravo"

        errors = ejournal.get_error_log fei

        assert_equal errors.length, 0

        assert ( ! ejournal.has_errors?(fei))
    end

end

