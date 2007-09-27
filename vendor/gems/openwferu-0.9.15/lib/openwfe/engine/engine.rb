#
#--
# Copyright (c) 2006-2007, John Mettraux, Nicolas Modrzyk OpenWFE.org
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
# . Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.  
# 
# . Redistributions in binary form must reproduce the above copyright notice, 
#   this list of conditions and the following disclaimer in the documentation 
#   and/or other materials provided with the distribution.
# 
# . Neither the name of the "OpenWFE" nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#++
#

#
# "made in Japan"
#
# John Mettraux at openwfe.org
# Nicolas Modrzyk at openwfe.org
# 

require 'logger'
require 'fileutils'

require 'openwfe/omixins'
require 'openwfe/rudefinitions'
require 'openwfe/service'
require 'openwfe/workitem'
require 'openwfe/util/irb'
require 'openwfe/util/scheduler'
require 'openwfe/util/schedulers'
require 'openwfe/expool/wfidgen'
require 'openwfe/expool/expressionpool'
require 'openwfe/expool/expstorage'
require 'openwfe/expool/errorjournal'
require 'openwfe/expressions/environment'
require 'openwfe/expressions/expressionmap'
require 'openwfe/participants/participantmap'


module OpenWFE

    #
    # The simplest implementation of the OpenWFE workflow engine.
    # No persistence is used, everything is stored in memory.
    #
    class Engine < Service
        include OwfeServiceLocator
        include FeiMixin

        #
        # Builds an OpenWFEru engine.
        #
        # Accepts an optional initial application_context (containing
        # initialization params for services for example).
        #
        # The engine itself uses one param :logger, used to define
        # where all the log output for OpenWFEru should go.
        # By default, this output goes to logs/openwferu.log
        #
        def initialize (application_context={})

            super(S_ENGINE, application_context)

            $OWFE_LOG = application_context[:logger]

            unless $OWFE_LOG
                #puts "Creating logs in " + FileUtils.pwd
                FileUtils.mkdir("logs") unless File.exist?("logs")
                $OWFE_LOG = Logger.new("logs/openwferu.log", 10, 1024000)
                $OWFE_LOG.level = Logger::INFO
            end

            # build order matters.
            #
            # especially for the expstorage which 'observes' the expression
            # pool and thus needs to be instantiated after it.

            build_scheduler()
                #
                # for delayed or repetitive executions (it's the engine's clock)
                # see http://openwferu.rubyforge.org/scheduler.html

            build_expression_map()
                #
                # mapping expression names ('sequence', 'if', 'concurrence', 
                # 'when'...) to their implementations (SequenceExpression,
                # IfExpression, ConcurrenceExpression, ...)

            build_wfid_generator()
                #
                # the workflow instance (process instance) id generator
                # making sure each process instance has a unique identifier

            build_expression_pool()
                #
                # the core (hairy ball) of the engine

            build_expression_storage()
                #
                # the engine persistence (persisting the expression instances
                # that make up process instances)

            build_participant_map()
                #
                # building the services that maps participant names to 
                # participant implementations / instances.

            build_error_journal()
                #
                # builds the error journal (keeping track of failures
                # in business process executions, and an opportunity to
                # fix and replay)

            linfo { "new() --- engine started --- #{self.object_id}" }
        end

        #
        # Call this method once the participants for a persisted engine
        # have been [re]added.
        #
        # If this method is called too soon, missing participants will 
        # cause trouble... Call this method after all the participants
        # have been added.
        #
        def reschedule

            get_expression_pool.reschedule()
        end

        alias :reload :reschedule

        #
        # When 'parameters' are used at the top of a process definition, this
        # method can be used to assert a launchitem before launch.
        # An expression will be raised if the parameters do not match the
        # requirements.
        #
        # Note that the launch method will raise those exceptions as well.
        # This method can be useful in some scenarii though.
        #
        def pre_launch_check (launchitem)

            get_expression_pool.prepare_raw_expression(launchitem)
        end

        #
        # Launches a [business] process.
        # The 'launch_object' param may contain either a LaunchItem instance, 
        # either a String containing the URL of the process definition
        # to launch (with an empty LaunchItem created on the fly).
        #
        # The launch object can also be a String containing the XML process
        # definition or directly a class extending OpenWFE::ProcessDefinition
        # (Ruby process definition).
        #
        # Returns the FlowExpressionId instance of the expression at the
        # root of the newly launched process.
        #
        # Options for scheduled launches like :at, :in and :cron are accepted
        # via the 'options' optional parameter.
        # For example :
        #
        #     engine.launch(launch_item)
        #         # will launch immediately
        #
        #     engine.launch(launch_item, :in => "1d20m")
        #         # will launch in one day and twenty minutes
        #
        #     engine.launch(launch_item, :at => "Tue Sep 11 20:23:02 +0900 2007")
        #         # will launch at that point in time
        #
        #     engine.launch(launch_item, :cron => "0 5 * * *")
        #         # will launch that same process every day,
        #         # five minutes after midnight (see "man 5 crontab")
        #
        def launch (launch_object, options={})

            launchitem = extract_launchitem launch_object

            fei = get_expression_pool.launch launchitem, options

            fei.dup
                #
                # so that users of this launch() method can play with their
                # fei without breaking things
        end

        #
        # This method is used to feed a workitem back to the engine (after
        # it got sent to a worklist or wherever by a participant).
        # Participant implementations themselves do call this method usually.
        #
        # This method also accepts LaunchItem instances.
        #
        def reply (workitem)

            if workitem.kind_of?(InFlowWorkItem)

                get_expression_pool.reply workitem.flow_expression_id, workitem

            elsif workitem.kind_of?(LaunchItem)

                get_expression_pool.launch workitem

            else

                raise \
                    "engine.reply() " +
                    "cannot handle instances of #{workitem.class}"
            end
        end

        alias :forward :reply
        alias :proceed :reply

        #
        # Registers a participant in this [embedded] engine.
        # This method is a shortcut to the ParticipantMap method
        # with the same name.
        #
        # Returns the participant instance.
        #
        # see ParticipantMap#register_participant
        #
        def register_participant (regex, participant=nil, &block)

            get_participant_map.register_participant(regex, participant, &block)
        end

        #
        # Given a participant name, returns the participant in charge
        # of handling workitems for that name.
        # May be useful in some embedded contexts.
        #
        def get_participant (participant_name)

            get_participant_map.lookup_participant(participant_name)
        end

        #
        # Removes the first participant matching the given name from the
        # participant map kept by the engine.
        #
        def unregister_participant (participant_name)

            get_participant_map.unregister_participant(participant_name)
        end

        #
        # Adds a workitem listener to this engine.
        #
        # The 'freq' parameters if present might indicate how frequently
        # the resource should be polled for incoming workitems.
        #
        #     engine.add_workitem_listener(listener, "3m10s")
        #        # every 3 minutes and 10 seconds
        #
        #     engine.add_workitem_listener(listener, "0 22 * * 1-5")
        #        # every weekday at 10pm
        #
        # TODO : block handling...
        #
        def add_workitem_listener (listener, freq=nil)

            name = nil

            if listener.kind_of? Class

                listener = init_service nil, listener

                name = listener.service_name
            else

                name = listener.name if listener.respond_to? :name
                name = "#{listener.class}::#{listener.object_id}" unless name

                @application_context[name] = listener
            end

            result = nil

            if freq

                freq = freq.to_s.strip

                result = if Scheduler.is_cron_string(freq)

                    get_scheduler.schedule(freq, listener)
                else

                    get_scheduler.schedule_every(freq, listener)
                end
            end

            linfo { "add_workitem_listener() added '#{name}'" }

            result
        end

        #
        # Makes the current thread join the engine's scheduler thread
        #
        # You can thus make an engine standalone with something like :
        #
        #     require 'openwfe/engine/engine'
        #
        #     the_engine = OpenWFE::Engine.new
        #     the_engine.join
        #
        # And you'll have to hit CTRL-C to make it stop.
        #
        def join

            get_scheduler.join
        end

        #
        # Calling this method makes the control flow block until the 
        # workflow engine is inactive.
        #
        # TODO : implement idle_for
        #
        def join_until_idle ()

            storage = get_expression_storage

            while storage.size > 1
                sleep 1
            end
        end

        #
        # Enabling the console means that hitting CTRL-C on the window /
        # term / dos box / whatever does run the OpenWFEru engine will
        # open an IRB interactive console for directly manipulating the
        # engine instance.
        #
        # Hit CTRL-D to get out of the console.
        #
        def enable_irb_console

            OpenWFE::trap_int_irb(binding)
        end

        #--
        # Makes sure that hitting CTRL-C will actually kill the engine VM and
        # not open an IRB console.
        #
        #def disable_irb_console
        #    $openwfe_irb = nil
        #    trap 'INT' do
        #        exit 0
        #    end
        #end
        #++

        #
        # Stopping the engine will stop all the services in the
        # application context.
        #
        def stop

            linfo { "stop() stopping engine '#{@service_name}'" }

            @application_context.each do |name, service|

                next if name == self.service_name

                #service.stop if service.respond_to? :stop

                if service.kind_of? ServiceMixin
                    service.stop
                    linfo do 
                        "stop() stopped service '#{service.service_name}' "+
                        "(#{service.class})"
                    end
                end
            end

            linfo { "stop() stopped engine '#{@service_name}'" }

            nil
        end

        #
        # Waits for a given process instance to terminate.
        # The method only exits when the flow terminates, but beware : if
        # the process already terminated, the method will never exit.
        #
        # The parameter can be a FlowExpressionId instance, for example the
        # one given back by a launch(), or directly a workflow instance id 
        # (String).
        #
        # This method is mainly used in utests.
        #
        def wait_for (fei_or_wfid)

            wfid = if fei_or_wfid.kind_of?(FlowExpressionId)
                fei_or_wfid.workflow_instance_id
            else
                fei_or_wfid
            end

            t = Thread.new { Thread.stop }

            to = get_expression_pool.add_observer(:terminate) do |c, fe, wi|
                t.wakeup if (fe.fei.workflow_instance_id == wfid and t.alive?)
            end
            te = get_expression_pool.add_observer(:error) do |c, fei, m, i, e|
                t.wakeup if (fei.parent_wfid == wfid and t.alive?)
            end

            linfo { "wait_for() #{wfid}" }

            t.join

            get_expression_pool.remove_observer(to, :terminate)
            get_expression_pool.remove_observer(te, :error)
                #
                # it would work as well without specifying the channel,
                # but it's thus a little bit faster
        end

        #
        # Returns a hash of ProcessStatus instances. The keys of the hash
        # are workflow instance ids.
        #
        # A ProcessStatus is a description of the state of a process instance.
        # It enumerates the expressions where the process is currently
        # located (waiting certainly) and the errors the process currently
        # has (hopefully none).
        #
        def list_process_status (wfid=nil)

            wfid = to_wfid(wfid) if wfid

            result = {}

            get_expression_storage.real_each(wfid) do |fei, fexp|
                next if fexp.kind_of?(Environment)
                next unless fexp.apply_time
                (result[fei.parent_wfid] ||= ProcessStatus.new) << fexp
            end

            result.values.each do |ps|
                get_error_journal.get_error_log(ps.wfid).each do |error|
                    ps << error
                end
            end

            class << result
                def to_s
                    pretty_print_process_status(self)
                end
            end

            result
        end

        #
        # list_process_status() will be deprecated at release 1.0.0
        #
        alias :get_process_status :list_process_status

        #
        # Returns the process status of one given process instance.
        #
        def process_status (wfid)

            wfid = to_wfid(wfid)

            list_process_status(wfid).values[0]
        end

        #--
        # METHODS FROM THE EXPRESSION POOL
        #
        # These methods are 'proxy' to method found in the expression pool.
        # They are made available here for a simpler model.
        #++

        #
        # Returns the list of applied expressions belonging to a given
        # workflow instance.
        # May be used to determine where a process instance currently is.
        #
        # This method returns all the expressions (the stack) a process
        # went through to reach its current state.
        #
        def get_process_stack (workflow_instance_id)

            get_expression_pool.get_process_stack(workflow_instance_id)
        end
        alias :get_flow_stack :get_process_stack

        #
        # Lists all workflow (process) instances currently in the expool (in
        # the engine).
        # This method will return a list of "process-definition" expressions
        # (i.e. OpenWFE::DefineExpression objects -- each representing the root
        # element of a flow).
        #
        # consider_subprocesses :: if true, "process-definition" expressions of 
        #                          subprocesses will be returned as well.
        # wfid_prefix :: allows your to query for specific workflow instance
        #                id prefixes.
        #
        def list_processes (consider_subprocesses=false, wfid_prefix=nil)

            get_expression_pool.list_processes(
                consider_subprocesses, wfid_prefix)
        end
        alias :list_workflows :list_processes

        #
        # Given any expression of a process, cancels the complete process
        # instance.
        #
        def cancel_process (exp_or_wfid)

            get_expression_pool.cancel_process(exp_or_wfid)
        end
        alias :cancel_flow :cancel_process

        #
        # Cancels the given expression (and its children if any)
        # (warning : advanced method)
        #
        # Cancelling the root expression of a process is equivalent to 
        # cancelling the process.
        #
        def cancel_expression (exp_or_fei)

            get_expression_pool.cancel_expression(exp_or_fei)
        end

        #
        # Forgets the given expression (make it an orphan)
        # (warning : advanced method)
        #
        def forget_expression (exp_or_fei)

            get_expression_pool.forget(exp_or_fei)
        end

        #
        # Pauses a process (sets its /__paused__ variable to true).
        #
        def pause_process (wfid)

            get_expression_pool.pause_process(wfid)
        end

        #
        # Restarts a process : removes its 'paused' flag (variable) and makes
        # sure to 'replay' events (replies) that came for it while it was
        # in pause.
        #
        def resume_process (wfid)

            get_expression_pool.resume_process(wfid)
        end

        #
        # Looks up a process variable in a process.
        # If fei_or_wfid is not given, will simply look in the 
        # 'engine environment' (where the top level variables '//' do reside).
        #
        def lookup_variable (var_name, fei_or_wfid=nil)

            return get_expression_pool.fetch_engine_environment[var_name] \
                unless fei_or_wfid

            exp = if fei_or_wfid.is_a?(String)

                get_expression_pool.fetch_root(fei_or_wfid)

            else

                get_expression_pool.fetch_expression(fei_or_wfid)
            end

            raise "no expression found for '#{fei_or_wfid.to_s}'" unless exp

            exp.lookup_variable var_name
        end

        protected

            #--
            # the following methods may get overridden upon extension
            # see for example file_persisted_engine.rb
            #++

            def build_expression_map

                @application_context[S_EXPRESSION_MAP] = ExpressionMap.new
                    #
                    # the expression map is not a Service anymore,
                    # it's a simple instance (that will be reused in other
                    # OpenWFEru components)
            end

            #
            # This implementation builds a KotobaWfidGenerator instance and
            # binds it in the engine context.
            # There are other WfidGeneration implementations available, like
            # UuidWfidGenerator or FieldWfidGenerator.
            #
            def build_wfid_generator

                #init_service S_WFID_GENERATOR, DefaultWfidGenerator
                #init_service S_WFID_GENERATOR, UuidWfidGenerator
                init_service S_WFID_GENERATOR, KotobaWfidGenerator

                #g = FieldWfidGenerator.new(
                #    S_WFID_GENERATOR, @application_context, "wfid")
                    #
                    # showing how to initialize a FieldWfidGenerator that
                    # will take as workflow instance id the value found in
                    # the field "wfid" of the LaunchItem.
            end

            #
            # Builds the OpenWFEru expression pool (the core of the engine)
            # and binds it in the engine context.
            # There is only one implementation of the expression pool, so
            # this method is usually never overriden.
            #
            def build_expression_pool

                init_service(S_EXPRESSION_POOL, ExpressionPool)
            end

            #
            # The implementation here builds an InMemoryExpressionStorage
            # instance.
            #
            # See FilePersistedEngine or CachedFilePersistedEngine for 
            # overrides of this method.
            #
            def build_expression_storage

                init_service(S_EXPRESSION_STORAGE, InMemoryExpressionStorage)
            end

            #
            # The ParticipantMap is a mapping between participant names 
            # (well rather regular expressions) and participant implementations
            # (see http://openwferu.rubyforge.org/participants.html)
            #
            def build_participant_map

                init_service(S_PARTICIPANT_MAP, ParticipantMap)
            end
            
            #
            # There is only one Scheduler implementation, that's the one
            # built and bound here.
            #
            def build_scheduler

                init_service(S_SCHEDULER, SchedulerService)
            end

            #
            # The default implementation of this method uses an 
            # InMemoryErrorJournal (do not use in production).
            #
            def build_error_journal

                init_service(S_ERROR_JOURNAL, InMemoryErrorJournal)
            end

            #
            # Turns the raw launch request info into a LaunchItem instance.
            #
            def extract_launchitem (launch_object)

                if launch_object.kind_of?(OpenWFE::LaunchItem)

                    launch_object

                elsif launch_object.kind_of?(Class)

                    LaunchItem.new launch_object

                elsif launch_object.kind_of?(String)

                    li = OpenWFE::LaunchItem.new

                    #if launch_object[0, 1] == '<' or launch_object.match("\n")
                    if launch_object[0, 1] == '<' or launch_object.index("\n")

                        li.workflow_definition_url = "field:__definition"
                        li['__definition'] = launch_object

                    else

                        li.workflow_definition_url = launch_object
                    end

                    li
                end
            end

    end

    #
    # ProcessStatus represents information about the status of a workflow
    # process instance.
    #
    # The status is mainly a list of expressions and a hash of errors.
    #
    # Instances of this class are obtained via Engine.process_status().
    #
    class ProcessStatus

        #
        # the String workflow instance id of the Process.
        #
        attr_reader :wfid

        #
        # The list of the expressions currently active in the process instance.
        #
        # For instance, if your process definition is currently in a 
        # concurrence, more than one expressions may be listed here.
        #
        attr_reader :expressions

        #
        # A hash whose values are ProcessError instances, the keys
        # are FlowExpressionId instances (fei) (identifying the expressions
        # that are concerned with the error)
        #
        attr_reader :errors

        def initialize
            @wfid = nil
            @expressions = []
            @errors = {}
        end

        #
        # Returns true if the process is in pause.
        #
        def paused?

            exp = @expressions[0]
            exp != nil and exp.paused?
        end

        #
        # this method is used by Engine.get_process_status() when
        # it prepares its results.
        #
        def << (item)

            if item.kind_of?(FlowExpression)
                add_expression item
            else
                add_error item
            end
        end

        #
        # A String representation, handy for debugging, quick viewing.
        #
        def to_s
            s = ""
            s << "-- #{self.class.name} --\n"
            s << "      wfid : #{@wfid}\n"
            s << "      expressions :\n"
            @expressions.each do |fexp|
                s << "         #{fexp.fei}\n"
            end
            s << "      errors : #{@errors.size}\n"
            s << "      paused : #{paused?}"
            s
        end

        protected

            def add_expression (fexp)

                set_wfid fexp.fei.parent_wfid

                #@expressions << fexp

                exps = @expressions
                @expressions = []

                added = false
                @expressions = exps.collect do |fe|
                    if added or fe.fei.wfid != fexp.fei.wfid
                        fe
                    else
                        if OpenWFE::starts_with(fexp.fei.expid, fe.fei.expid)
                            added = true
                            fexp
                        elsif OpenWFE::starts_with(fe.fei.expid, fexp.fei.expid)
                            added = true
                            fe
                        else
                            fe
                        end
                    end
                end
                @expressions << fexp unless added
            end

            def add_error (error)
                @errors[error.fei] = error
            end

            def set_wfid (wfid)

                return if @wfid
                @wfid = wfid
            end
    end

    #
    # Renders a nice, terminal oriented, representation of an 
    # Engine.get_process_status() result.
    #
    # You usually directly benefit from this when doing
    #
    #     puts engine.get_process_status.to_s
    #
    def pretty_print_process_status (ps)

        s = ""
        s << "process_id          | name              | rev     | brn | err | paused? \n"
        s << "--------------------+-------------------+---------+-----+-----+---------\n"

        ps.keys.sort.each do |wfid|

            status = ps[wfid]
            fexp = status.expressions[0]
            ffei = fexp.fei

            s << "%-19s" % wfid[0, 19]
            s << " | "
            s << "%-17s" % ffei.workflow_definition_name[0, 17]
            s << " | "
            s << "%-7s" % ffei.workflow_definition_revision[0, 7]
            s << " | "
            s << "%3s" % status.expressions.size.to_s[0, 3]
            s << " | "
            s << "%3s" % status.errors.size.to_s[0, 3]
            s << " | "
            s << "%5s" % status.paused?.to_s
            s << "\n"
        end
        s
    end

end

