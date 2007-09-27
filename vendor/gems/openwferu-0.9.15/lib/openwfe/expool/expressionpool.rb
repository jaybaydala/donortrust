#
#--
# Copyright (c) 2006-2007, John Mettraux, OpenWFE.org
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
#

require 'uri'
require 'monitor'
require 'open-uri'
require 'rexml/document'

require 'openwfe/utils'
require 'openwfe/service'
require 'openwfe/logging'
require 'openwfe/omixins'
require 'openwfe/rudefinitions'
require 'openwfe/flowexpressionid'
require 'openwfe/util/lru'
require 'openwfe/util/safe'
require 'openwfe/util/workqueue'
require 'openwfe/util/observable'
require 'openwfe/expressions/environment'
require 'openwfe/expressions/raw_xml'
require 'openwfe/expressions/raw_prog'
require 'openwfe/expressions/simplerep'

include OpenWFE


module OpenWFE

    GONE = "gone"

    #
    # This special flow expression id is used by the forget() method
    # (which is used by the forget expression and the concurrence
    # synchronization expressions)
    #
    GONE_PARENT_ID = FlowExpressionId.new
    GONE_PARENT_ID.owfe_version = "any"
    GONE_PARENT_ID.engine_id = GONE
    GONE_PARENT_ID.initial_engine_id = GONE
    GONE_PARENT_ID.workflow_definition_url = GONE
    GONE_PARENT_ID.workflow_definition_name = GONE
    GONE_PARENT_ID.workflow_definition_revision = GONE
    GONE_PARENT_ID.workflow_instance_id = "-1"
    GONE_PARENT_ID.expression_name = GONE
    GONE_PARENT_ID.expression_id = "-1"
    GONE_PARENT_ID.freeze

    #
    # The ExpressionPool stores expressions (pieces of workflow instance).
    # It's the core of the workflow engine.
    # It relies on an expression storage for actual persistence of the
    # expressions.
    #
    class ExpressionPool
        include ServiceMixin
        include OwfeServiceLocator 
        include OwfeObservable
        include WorkqueueMixin
        include FeiMixin
        include MonitorMixin 


        #
        # code loaded from a remote URI will get evaluated with 
        # that security level
        #
        SAFETY_LEVEL = 2

        def initialize (service_name, application_context)

            super()

            service_init(service_name, application_context)

            @monitors = MonitorProvider.new(application_context)

            @observers = {}

            @stopped = false

            engine_environment_id
                # makes sure it's called now

            start_workqueue
        end

        #
        # Stops this expression pool (especially its workqueue).
        #
        def stop

            @stopped = true

            stop_workqueue
                #
                # flushes the work queue

            onotify :stop
        end

        #
        # Obtains a unique monitor for an expression.
        # It avoids the need for the FlowExpression instances to include
        # the monitor mixin by themselves
        #
        def get_monitor (fei)

            @monitors[fei]
        end

        #
        # This method is called by the launch method. It's actually the first 
        # stage of that method.
        # It may be interessant to use to 'validate' a launchitem and its
        # process definition, as it will raise an exception in case 
        # of 'parameter' mismatch.
        #
        # There is a 'pre_launch_check' alias for this method in the
        # Engine class.
        #
        def prepare_raw_expression (launchitem)

            wfdurl = launchitem.workflow_definition_url

            raise "launchitem.workflow_definition_url not set, cannot launch" \
                unless wfdurl

            definition = if wfdurl.match "^field:"
                wfdfield = wfdurl[6..-1]
                launchitem.attributes.delete wfdfield
            else
                read_uri(wfdurl)
            end

            raise "didn't find process definition at '#{wfdurl}'" \
                unless definition

            raw_expression = build_raw_expression launchitem, definition

            raw_expression.check_parameters launchitem
                #
                # will raise an exception if there are requirements
                # and one of them is not met

            raw_expression
        end

        #
        # Instantiates a workflow definition and launches it.
        #
        # This method call will return immediately, it could even return
        # before the actual launch is completely over.
        #
        # Returns the FlowExpressionId instance of the root expression of
        # the newly launched flow.
        #
        def launch (launchitem, options)

            #
            # prepare raw expression

            raw_expression = prepare_raw_expression launchitem
                #
                # will raise an exception if there are requirements
                # and one of them is not met

            raw_expression.new_environment()
                #
                # as this expression is the root of a new process instance,
                # it has to have an environment for all the variables of 
                # the process instance

            raw_expression = wrap_in_schedule(raw_expression, options) \
                if options and options.size > 0

            fei = raw_expression.fei

            #
            # apply prepared raw expression

            wi = build_workitem launchitem

            onotify :launch, fei, launchitem

            apply raw_expression, wi

            fei
        end

        #
        # Prepares a raw expression from a template.
        # Returns that raw expression.
        #
        # Used in the concurrent-iterator when building up the children list 
        # and of course used by the launch_template() method.
        #
        def prepare_from_template (
            requesting_expression, sub_id, template, params=nil)

            rawexp = if template.is_a?(RawExpression)
                template
            elsif template.is_a?(FlowExpressionId)
                fetch_expression(template)
            else
                build_raw_expression(nil, template)
            end

            #raise "did not find subprocess in : #{template.to_s}" \
            #    unless rawexp

            rawexp = rawexp.dup()
            rawexp.fei = rawexp.fei.dup()

            if requesting_expression == nil

                rawexp.parent_id = nil
                rawexp.fei.workflow_instance_id = get_wfid_generator.generate

            elsif requesting_expression.kind_of?(FlowExpressionId)

                rawexp.parent_id = requesting_expression
                rawexp.fei.workflow_instance_id = \
                    "#{requesting_expression.workflow_instance_id}.#{sub_id}"

            elsif requesting_expression.kind_of?(String)

                rawexp.parent_id = nil
                rawexp.fei.workflow_instance_id = \
                    "#{requesting_expression}.#{sub_id}"

            else # kind is FlowExpression

                rawexp.parent_id = requesting_expression.fei
                rawexp.fei.workflow_instance_id = \
                    "#{requesting_expression.fei.workflow_instance_id}.#{sub_id}"
            end

            #ldebug do
            #    "launch_template() spawning wfid " +
            #    "#{rawexp.fei.workflow_instance_id.to_s}"
            #end

            env = rawexp.new_environment(params)
                #
                # the new scope gets its own environment

            rawexp.store_itself()

            rawexp
        end

        #
        # launches a subprocess
        #
        def launch_template (
            requesting_expression, sub_id, template, workitem, params=nil)

            rawexp = prepare_from_template(
                requesting_expression, sub_id, template, params)

            workitem.flow_expression_id = rawexp.fei

            onotify :launch_template, rawexp.fei, workitem

            apply rawexp, workitem

            rawexp.fei
        end

        #
        # Evaluates a raw definition expression and
        # returns its body fei
        #
        def evaluate (rawExpression, workitem)

            exp = rawExpression.instantiate_real_expression workitem
            fei = exp.evaluate workitem

            #remove(rawExpression)
                #
                # not necessary, the raw expression gets overriden by
                # the real expression

            fei
        end

        #
        # Applies a given expression (id or expression)
        #
        def apply (exp, workitem)

            queue_work :do_apply, exp, workitem
        end

        #
        # Replies to a given expression
        #
        def reply (exp, workitem)

            queue_work :do_reply, exp, workitem
        end

        #
        # Cancels the given expression.
        # The param might be an expression instance or a FlowExpressionId 
        # instance.
        #
        def cancel (exp)

            exp, fei = fetch(exp)

            unless exp
                ldebug { "cancel() cannot cancel missing  #{fei.to_debug_s}" }
                return nil
            end

            ldebug { "cancel() for  #{fei.to_debug_s}" }

            onotify :cancel, exp

            inflowitem = exp.cancel()
            remove(exp)

            inflowitem
        end

        #
        # Cancels the given expression and makes sure to resume the flow
        # if the expression or one of its children were active.
        #
        # If the cancelled branch was not active, this method will take
        # care of removing the cancelled expression from the parent
        # expression.
        #
        def cancel_expression (exp)

            exp = fetch_expression(exp)

            wi = cancel(exp)

            if wi
                reply_to_parent(exp, wi, false)
            else
                parent_exp = fetch_expression(exp.parent_id)
                parent_exp.remove_child(exp.fei) if parent_exp
            end
        end

        #
        # Given any expression of a process, cancels the complete process
        # instance.
        #
        def cancel_process (exp_or_wfid)

            ldebug { "cancel_process() from  #{exp_or_wfid}" }

            root = fetch_root(exp_or_wfid)
            cancel(root)
        end
        alias :cancel_flow :cancel_process

        #
        # Forgets the given expression (makes sure to substitute its
        # parent_id with the GONE_PARENT_ID constant)
        #
        def forget (parent_exp, exp)

            exp, fei = fetch(exp)

            #ldebug { "forget() forgetting  #{fei}" }

            return if not exp

            onotify :forget, exp

            parent_exp.children.delete(fei)

            exp.parent_id = GONE_PARENT_ID
            exp.dup_environment
            exp.store_itself()

            ldebug { "forget() forgot      #{fei}" }
        end

        #
        # Pauses a process (sets its '/__paused__' variable to true).
        #
        def pause_process (wfid)

            wfid = extract_wfid(wfid)

            root_expression = fetch_root(wfid)

            root_expression.set_variable(VAR_PAUSED, true)
        end

        #
        # Restarts a process : removes its 'paused' flag (variable) and makes
        # sure to 'replay' events (replies) that came for it while it was
        # in pause.
        #
        def resume_process (wfid)

            wfid = extract_wfid(wfid)

            root_expression = fetch_root(wfid)

            #
            # remove 'paused' flag

            root_expression.unset_variable(VAR_PAUSED)

            #
            # replay

            journal = get_error_journal

            # select PausedError instances in separate list

            errors = journal.get_error_log(wfid)
            error_class = PausedError.name
            paused_errors = errors.select { |e| e.error_class == error_class }

            return if paused_errors.size < 1

            # remove them from current error journal

            journal.remove_errors wfid, paused_errors

            # replay select PausedError instances

            paused_errors.each do |e|
                journal.replay_at_error e
            end
        end

        #
        # Replies to the parent of the given expression.
        #
        def reply_to_parent (exp, workitem, remove=true)

            ldebug { "reply_to_parent() for #{exp.fei.to_debug_s}" }

            workitem.last_expression_id = exp.fei

            onotify :reply_to_parent, exp, workitem

            if remove

                remove(exp)
                    #
                    # remove the expression itself

                exp.clean_children()
                    #
                    # remove all the children of the expression
            end

            #
            # manage tag, have to remove it so it can get 'redone' or 'undone'
            # (preventing abuse)

            tagname = exp.attributes["tag"] if exp.attributes

            exp.delete_variable(tagname) if tagname

            #
            # flow terminated ?

            if not exp.parent_id

                ldebug do 
                    "reply_to_parent() process " +
                    "#{exp.fei.workflow_instance_id} terminated"
                end

                onotify :terminate, exp, workitem

                return
            end

            #
            # else, gone parent ?

            if exp.parent_id == GONE_PARENT_ID
                ldebug do
                    "reply_to_parent() parent is gone for  " +
                    exp.fei.to_debug_s
                end

                return
            end

            #
            # parent still present, reply to it

            reply exp.parent_id, workitem
        end

        #
        # Adds or updates a flow expression in this pool
        #
        def update (flow_expression)

            #ldebug { "update() for #{flow_expression.fei.to_debug_s}" }

            t = Timer.new

            onotify :update, flow_expression.fei, flow_expression

            ldebug do 
                "update() took #{t.duration} ms  " +
                "#{flow_expression.fei.to_debug_s}"
            end

            flow_expression
        end

        #
        # Fetches a FlowExpression from the pool.
        # Returns a tuple : the FlowExpression plus its FlowExpressionId.
        #
        # The param 'exp' may be a FlowExpressionId or a FlowExpression that
        # has to be reloaded.
        # 
        def fetch (exp)
            synchronize do

                fei = exp

                #ldebug { "fetch() exp is of kind #{exp.class}" }

                if exp.kind_of?(FlowExpression)
                    fei = exp.fei 
                elsif not exp.kind_of?(FlowExpressionId)
                    raise \
                        "Cannot fetch expression with key : "+
                        "'#{fei}' (#{fei.class})"
                end

                #ldebug { "fetch() for  #{fei.to_debug_s}" }

                [ get_expression_storage()[fei], fei ]
            end
        end

        #
        # Fetches a FlowExpression (returns only the FlowExpression instance)
        #
        # The param 'exp' may be a FlowExpressionId or a FlowExpression that
        # has to be reloaded.
        #
        def fetch_expression (exp)

            exp, _fei = fetch(exp)
            exp
        end

        #
        # Fetches the root expression of a process (given any of its
        # expressions or its wfid).
        #
        def fetch_root (exp_or_wfid)

            return fetch_expression_with_wfid(exp_or_wfid) \
                if exp_or_wfid.is_a?(String)

            exp = fetch_expression(exp_or_wfid)

            raise "did not find root for expression #{exp_or_wfid}" unless exp

            return exp unless exp.parent_id

            fetch_root(fetch_expression(exp.parent_id))
        end

        #
        # Returns the engine environment (the top level environment)
        #
        def fetch_engine_environment ()
            synchronize do
                #
                # synchronize to ensure that there's 1! engine env

                eei = engine_environment_id
                ee, fei = fetch(eei)

                if not ee
                    ee = Environment\
                        .new(eei, nil, nil, @application_context, nil)
                    ee.store_itself()
                end

                ee
            end
        end

        #
        # Removes a flow expression from the pool
        # (This method is mainly called from the pool itself)
        #
        def remove (exp)

            exp, _fei = fetch(exp) \
                if exp.kind_of?(FlowExpressionId)

            return unless exp

            ldebug { "remove() fe  #{exp.fei.to_debug_s}" }

            onotify :remove, exp.fei

            synchronize do

                @monitors.delete(exp.fei)

                remove_environment(exp.environment_id) \
                    if exp.owns_its_environment?
            end
        end

        #
        # This method is called at each expool (engine) [re]start.
        # It roams through the previously saved (persisted) expressions
        # to reschedule ones like 'sleep' or 'cron'.
        #
        def reschedule

            return if @stopped

            synchronize do

                t = OpenWFE::Timer.new

                linfo { "reschedule() initiating..." }

                get_expression_storage.each_of_kind(Schedulable) do |fe|

                    #linfo { "reschedule() for  #{fe.fei.to_debug_s}..." }
                    linfo { "reschedule() for  #{fe.fei.to_s}..." }

                    onotify :reschedule, fe.fei

                    fe.reschedule(get_scheduler)
                end

                linfo { "reschedule() done. (took #{t.duration} ms)" }
            end
        end

        #
        # Returns the unique engine_environment FlowExpressionId instance.
        # There is only one such environment in an engine, hence this 
        # 'singleton' method.
        #
        def engine_environment_id ()
            #synchronize do

            return @eei if @eei

            @eei = FlowExpressionId.new
            @eei.owfe_version = OPENWFERU_VERSION
            @eei.engine_id = get_engine.service_name
            @eei.initial_engine_id = @eei.engine_id
            @eei.workflow_definition_url = 'ee'
            @eei.workflow_definition_name = 'ee'
            @eei.workflow_definition_revision = '0'
            @eei.workflow_instance_id = '0'
            @eei.expression_name = EN_ENVIRONMENT
            @eei.expression_id = '0'
            @eei
            #end
        end

        #
        # Returns the list of applied expressions belonging to a given
        # workflow instance.
        #
        def get_process_stack (wfid)

            raise "please provide a non-nil workflow instance id" \
                unless wfid

            wfid = to_wfid wfid

            result = []

            get_expression_storage.real_each do |fei, fexp|

                next if fexp.kind_of?(Environment)
                next if fexp.kind_of?(RawExpression)
                next unless fexp.apply_time

                next if fei.parent_wfid != wfid

                result << fexp
            end

            ldebug do 
                "process_stack() " +
                "found #{result.size} exps for flow #{wfid}" 
            end

            result
        end

        alias :get_flow_stack :get_process_stack

        #
        # Lists all workflows (processes) currently in the expool (in
        # the engine).
        # This method will return a list of "process-definition" expressions
        # (root of flows).
        #
        # If consider_subprocesses is set to true, "process-definition" 
        # expressions of subprocesses will be returned as well.
        #
        # "wfid_prefix" allows your to query for specific workflow instance
        # id prefixes.
        #
        def list_processes (consider_subprocesses=false, wfid_prefix=nil)

            result = []

            # collect() would look better

            get_expression_storage.real_each(wfid_prefix) do |fei, fexp|

                next unless fexp.is_a? DefineExpression

                next if not consider_subprocesses and fei.wfid.index(".")

                #next unless fei.wfid.match("^#{wfid_prefix}") if wfid_prefix

                result << fexp
            end

            result
        end

        #
        # Returns the first expression found with the given wfid.
        #
        def fetch_expression_with_wfid (wfid)

            list_processes(false, wfid)[0]
        end

        #
        # This method is called when apply() or reply() failed for
        # an expression.
        # There are currently only two 'users', the ParticipantExpression
        # class and the do_process_workelement method of this ExpressionPool
        # class.
        #
        def notify_error (error, fei, message, workitem)

            fei = extract_fei fei
                # densha requires that... :(

            se = OpenWFE::exception_to_s(error)

            onotify :error, fei, message, workitem, error.class.name, se

            #fei = extract_fei fei

            if error.is_a?(PausedError)
                lwarn do
                    "#{self.service_name} " +
                    "operation :#{message.to_s} on #{fei.to_s} " +
                    "delayed because process '#{fei.wfid}' is in pause"
                end
            else
                lwarn do
                    "#{self.service_name} " +
                    "operation :#{message.to_s} on #{fei.to_s} " +
                    "failed with\n" + se
                end
            end
        end

        protected

            #--
            # Returns true if it's the fei of a participant 
            # (or of a subprocess ref)
            #
            #def is_participant? (fei)
            #    exp_name = fei.expression_name
            #    return true if exp_name == "participant"
            #    (get_expression_map.get_class(exp_name) == nil)
            #end
            #++

            #
            # This method is called by the workqueue when processing
            # the atomic work operations.
            #
            def do_process_workelement elt

                message, fei, workitem = elt

                begin

                    send message, fei, workitem

                rescue Exception => e

                    notify_error(e, fei, message, workitem)
                end
            end

            #
            # The real apply work.
            #
            def do_apply (exp, workitem)

                exp, fei = fetch(exp) if exp.kind_of?(FlowExpressionId)

                check_if_paused exp

                #ldebug { "apply()  '#{fei}' (#{fei.class})" }

                if not exp

                    lwarn { "apply() cannot apply missing  #{fei.to_debug_s}" }
                    return

                    #raise "apply() cannot apply missing  #{fei.to_debug_s}"
                end

                #ldebug { "apply()  #{fei.to_debug_s}" }

                #exp.apply_time = OpenWFE::now()
                    #
                    # this is done in RawExpression

                workitem.flow_expression_id = exp.fei

                onotify :apply, exp, workitem

                exp.apply(workitem)
            end

            #
            # The real reply work is done here
            #
            def do_reply (exp, workitem)

                exp, fei = fetch(exp)

                ldebug { "reply() to   #{fei.to_debug_s}" }
                ldebug { "reply() from #{workitem.last_expression_id.to_debug_s}" }

                check_if_paused exp

                if not exp
                    #raise "cannot reply to missing  #{fei.to_debug_s}"
                    lwarn { "reply() cannot reply to missing  #{fei.to_debug_s}" }
                    return
                end

                onotify :reply, exp, workitem

                exp.reply(workitem)
            end

            #
            # Will raise an exception if the expression belongs to a paused
            # process.
            #
            def check_if_paused (expression)

                return unless expression

                raise PausedError.new(expression.fei.wfid) \
                    if expression.paused?
            end

            #
            # if the launch method is called with a schedule option
            # (like :at, :in, :cron and :every), this method takes care of 
            # wrapping the process with a sleep or a cron.
            #
            def wrap_in_schedule (raw_expression, options)

                oat = options[:at]
                oin = options[:in]
                ocron = options[:cron]
                oevery = options[:every]

                fei = new_fei(nil, "schedlaunch", "0", "sequence")

                # not very happy with this code, it builds custom
                # wrapping processes manually, maybe there is 
                # a more elegant way, but for now, it's ok.

                if oat or oin

                    seq = get_expression_map.get_class(:sequence)
                    seq = seq.new(fei, nil, nil, application_context, nil)

                    att = if oat
                        { "until" => oat }
                    else #oin
                        { "for" => oin }
                    end

                    sle = get_expression_map.get_class(:sleep)
                    sle = sle.new(fei.dup, fei, nil, application_context, att)
                    sle.fei.expression_id = "0.1"
                    sle.fei.expression_name = "sleep"
                    seq.children << sle.fei
                    seq.children << raw_expression.fei

                    seq.new_environment
                    sle.environment_id = seq.environment_id

                    sle.store_itself
                    seq.store_itself

                    raw_expression.store_itself
                    raw_expression = seq

                elsif ocron or oevery

                    fei.expression_name = "cron"

                    att = if ocron
                        { "tab" => ocron }
                    else #oevery
                        { "every" => oevery }
                    end
                    att["name"] = "//cron_launch__#{fei.wfid}"

                    cro = get_expression_map.get_class(:cron)
                    cro = cro.new(fei, nil, nil, application_context, att)

                    cro.children << raw_expression.fei

                    cro.new_environment

                    cro.store_itself

                    raw_expression.store_itself
                    raw_expression = cro
                end
                    # else, don't schedule at all

                raw_expression
            end

            #
            # Removes an environment, especially takes care of unbinding
            # any special value it may contain.
            #
            def remove_environment (environment_id)

                ldebug { "remove_environment()  #{environment_id.to_debug_s}" }

                env, fei = fetch(environment_id)

                return unless env
                    #
                    # env already unbound and removed

                env.unbind

                #get_expression_storage().delete(environment_id)

                onotify :remove, environment_id
            end

            #
            # Prepares a new instance of InFlowWorkItem from a LaunchItem
            # instance.
            #
            def build_workitem (launchitem)

                wi = InFlowWorkItem.new

                wi.attributes = launchitem.attributes.dup

                wi
            end

            #
            # This is the only point in the expression pool where an URI
            # is read, so this is where the :remote_definitions_allowed
            # security check is enforced.
            #
            def read_uri (uri)

                uri = uri.to_s
                uri = uri[5..-1] if uri.match("^file:")
                uri = URI.parse(uri)

                if uri.scheme
                    raise "loading remote definitions is not allowed" \
                        if ac[:remote_definitions_allowed] != true
                end

                open(uri.to_s).read
            end

            #
            # The parameter to this method might be either a process
            # definition (in any form) or a LaunchItem.
            #
            # Will return a 'representation' (what is used to build
            # a RawExpression instance).
            #
            def determine_representation (param)

                #ldebug do 
                #    "determine_representation() from class #{param.class.name}"
                #end

                param = read_uri(param) if param.is_a?(URI)

                #ldebug do 
                #    "determine_representation() " +
                #    "param of class #{param.class.name}" 
                #end

                return param \
                    if param.is_a?(SimpleExpRepresentation)

                return param.do_make \
                    if param.is_a?(ProcessDefinition) or param.is_a?(Class)

                raise "cannot handle definition of class #{param.class.name}" \
                    unless param.is_a? String

                if param[0, 1] == "<"
                    #
                    # XML definition

                    xmlRoot = REXML::Document.new(param).root
                    class << xmlRoot
                        def raw_expression_class
                            XmlRawExpression
                        end
                    end
                    return xmlRoot
                end

                return YAML.load(s) if param.match("^--- .")
                    #
                    # something that was dumped via YAML

                #
                # else it's some ruby code to eval

                ProcessDefinition::eval_ruby_process_definition(
                    param, SAFETY_LEVEL)
            end

            #
            # Builds a FlowExpressionId instance for a process being
            # launched.
            #
            def new_fei (launchitem, flow_name, flow_revision, exp_name)

                url = if launchitem
                    launchitem.workflow_definition_url
                else
                    "no-url"
                end

                fei = FlowExpressionId.new

                fei.owfe_version = OPENWFERU_VERSION
                fei.engine_id = OpenWFE::stu get_engine.service_name
                fei.initial_engine_id = OpenWFE::stu fei.engine_id
                fei.workflow_definition_url = OpenWFE::stu url
                fei.workflow_definition_name = OpenWFE::stu flow_name
                fei.workflow_definition_revision = OpenWFE::stu flow_revision
                fei.wfid = get_wfid_generator.generate launchitem
                fei.expression_id = "0"
                fei.expression_name = exp_name

                fei
            end

            #
            # Builds the RawExpression instance at the root of the flow
            # being launched.
            #
            # The param can be a template or a definition (anything
            # accepted by the determine_representation() method).
            #
            def build_raw_expression (launchitem, param)

                procdef = determine_representation(param)

                #return procdef if procdef.is_a? RawExpression

                flow_name = procdef.attributes['name']
                flow_revision = procdef.attributes['revision']
                exp_name = procdef.name

                fei = new_fei(launchitem, flow_name, flow_revision, exp_name)

                #puts procdef.raw_expression_class
                #puts procdef.raw_expression_class.public_methods

                procdef.raw_expression_class.new(
                    fei, nil, nil, @application_context, procdef)
            end
    end

    #
    # This error is raised when an expression belonging to a paused
    # process is applied or replied to.
    #
    class PausedError < RuntimeError

        attr_reader :wfid

        def initialize (wfid)

            super "process '#{wfid}' is paused"
            @wfid = wfid
        end

        #
        # Returns a hash for this PausedError instance.
        # (simply returns the hash of the paused process' wfid).
        #
        def hash

            @wfid.hash
        end

        #
        # Returns true if the other is a PausedError issued for the
        # same process instance (wfid).
        #
        def == (other)

            return false unless other.is_a?(PausedError)

            (@wfid == other.wfid)
        end
    end

    #
    # a small help class for storing monitors provided on demand 
    # to expressions that need them
    #
    class MonitorProvider
        include MonitorMixin, Logging

        MAX_MONITORS = 10000

        def initialize (application_context=nil)
            super()
            @application_context = application_context
            @monitors = LruHash.new(MAX_MONITORS)
        end

        def [] (key)
            synchronize do

                (@monitors[key] ||= Monitor.new)
            end
        end

        def delete (key)
            synchronize do
                #ldebug { "delete() removing Monitor for  #{key}" }
                @monitors.delete(key)
            end
        end
    end

end

