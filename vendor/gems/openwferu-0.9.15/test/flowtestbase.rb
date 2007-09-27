#_
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
require 'openwfe/engine/engine'
require 'openwfe/rudefinitions'
require 'openwfe/participants/participants'

require 'rutest_utils'

include OpenWFE


$WORKFLOW_ENGINE_CLASS = Engine

persistence = ENV["__persistence__"]

require "openwfe/engine/file_persisted_engine" if persistence

if persistence == "pure-persistence"
    $WORKFLOW_ENGINE_CLASS = FilePersistedEngine
elsif persistence == "cached-persistence"
    $WORKFLOW_ENGINE_CLASS = CachedFilePersistedEngine
end
    

puts
puts "testing with engine of class " + $WORKFLOW_ENGINE_CLASS.to_s
puts

module FlowTestBase

    attr_reader \
        :engine, :tracer

    #
    # SETUP
    #
    def setup

        @engine = $WORKFLOW_ENGINE_CLASS.new

        @engine.application_context[:ruby_eval_allowed] = true

        @tracer = Tracer.new
        @engine.application_context["__tracer"] = @tracer

        @engine.register_participant('pp-workitem') do |workitem|

            puts
            require 'pp'; pp workitem
            puts
        end

        @engine.register_participant('pp-fields') do |workitem|

            workitem.attributes.keys.sort.each do |field|
                next if field == "___map_type" or field == "__result__"
                next if field == "params"
                @tracer << "#{field}: #{workitem.attributes[field]}\n"
            end
            @tracer << "--\n"
        end

        @engine.register_participant('test-.*', PrintParticipant.new())

        @engine.register_participant('block-participant') do |workitem|
            @tracer << "the block participant received a workitem"
            @tracer << "\n"
        end

        @engine.register_participant('p-toto') do |workitem|
            @tracer << "toto"
        end
    end

    #
    # TEARDOWN
    #
    def teardown
        if @engine
            $OWFE_LOG.level = Logger::INFO
            @engine.stop 
        end
    end

    protected

        def log_level_to_debug
            $OWFE_LOG.level = Logger::DEBUG
        end

        def print_exp_list (l)
            puts
            l.each do |fexp|
                puts "   - #{fexp.fei.to_debug_s}"
            end
            puts
        end

        def name_of_test
            s = caller(1)[0]
            i = s.index('`')
            #s = s[i+1..s.length-2]
            s = s[i+6..s.length-2]
            s
        end

        #
        # dotest()
        #
        def dotest (
            flowDef, expectedTrace, join=false, allowRemainingExpressions=false)

            @tracer.clear

            li = if flowDef.kind_of? OpenWFE::LaunchItem
                flowDef
            else
                OpenWFE::LaunchItem.new(flowDef)
            end

            fei = @engine.launch(li)

            $OWFE_LOG.info { "dotest() launched #{fei.to_s}" }

            if join.is_a?(Numeric)
                sleep join
            else
                @engine.wait_for fei
            end

            trace = @tracer.to_s

            #puts "...'#{trace}' ?= '#{expectedTrace}'"

            if expectedTrace.kind_of?(Array)

                result = false
                expectedTrace.each do |etrace|
                    result = (result or (trace == etrace))
                end
                unless result
                    puts
                    puts ">#{trace}<"
                    puts
                end
                assert \
                    result,
                    "flow failed : trace doesn't correspond to any expected traces"
            elsif expectedTrace.kind_of? Regexp

                assert \
                    trace.match(expectedTrace)
            else

                assert \
                    trace == expectedTrace,
                    """flow failed : 
                    
'#{trace}'

  != 

'#{expectedTrace}'
"""
            end

            if allowRemainingExpressions

                purge_engine

                return fei
            end

            exp_storage = engine.get_expression_storage
            size = exp_storage.size

            if size != 1
                puts
                puts "    remaining expressions : #{exp_storage.length}"
                puts
                puts exp_storage.to_s
                puts
                puts OpenWFE::caller_to_s(0, 2)
                puts

                purge_engine
            end

            assert_equal(
                size,
                1,
                "there are expressions remaining in the expression pool " +
                "(#{exp_storage.length})")

            fei
        end

        def purge_engine

            @engine.get_expression_storages.each do |storage|
                storage.purge
            end
        end

end

#
# A bunch of methods for testing the journal component
#
module JournalTestBase

    def get_journal
        @engine.get_journal
    end

    def get_error_count (wfid)

        fn = get_journal.workdir + "/" + wfid + ".journal"

        get_journal.flush_buckets

        events = get_journal.load_events(fn)

        error_count = 0
        events.each { |evt| error_count += 1 if evt[0] == :error }

        error_count
    end
end

