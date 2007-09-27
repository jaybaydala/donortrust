
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Tue Aug 21 10:22:18 JST 2007
#

require 'test/unit'

require 'find'

require 'openwfe/engine/file_persisted_engine'
require 'openwfe/worklist/storeparticipant'


#
# fighting bug at : 
# http://rubyforge.org/tracker/index.php?func=detail&aid=13238&group_id=2609&atid=10023
#

class RubyProcDefTest < Test::Unit::TestCase

    def setup

        @engine = OpenWFE::CachedFilePersistedEngine.new

        @engine.register_participant :alpha, OpenWFE::HashParticipant
    end

    def teardown

        @engine.stop if @engine
    end

    #
    # TESTS

    class Test0 < OpenWFE::ProcessDefinition
        sequence do
            alpha
        end
    end

    def test_0

        fei0 = @engine.launch Test0
        sleep 0.100
        fei1 = @engine.launch Test0
        sleep 0.200

        stack0 = @engine.get_process_stack fei0.wfid
        #puts stack0
        stack1 = @engine.get_process_stack fei1.wfid
        #puts stack1

        assert_equal stack0.size, 3
        assert_equal stack1.size, 3

        assert_equal count_files(fei0.wfid), 4
        assert_equal count_files(fei1.wfid), 4

        @engine.cancel_process(fei0.wfid)
        @engine.cancel_process(fei1.wfid)

        sleep 0.100
    end


    TEST1 = """
class Test1 < OpenWFE::ProcessDefinition
    sequence do
        alpha
    end
end
    """

    def test_1

        fei0 = launch TEST1
        sleep 0.100
        fei1 = launch TEST1
        sleep 0.100

        assert_equal ProcessDefinition.extract_class(TEST1), Test1

        stack0 = @engine.get_process_stack fei0.wfid
        #puts stack0
        stack1 = @engine.get_process_stack fei1.wfid
        #puts stack1

        assert_equal stack0.size, 3
        assert_equal stack1.size, 3

        assert_equal count_files(fei0.wfid), 4
        assert_equal count_files(fei1.wfid), 4

        @engine.cancel_process(fei0.wfid)
        @engine.cancel_process(fei1.wfid)

        sleep 0.100
    end

    protected

        def launch (test_string)

            filename = "work/procdef.rb"

            File.open(filename, "w") do |f|
                f.puts test_string
            end
            @engine.launch filename
        end

        def count_files (wfid)

            count = 0

            Find.find("work/expool/") do |path|
                next unless path.match(wfid+"__.*\.yaml")
                count += 1
            end

            count
        end

end
