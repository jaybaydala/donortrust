#
#--
# Copyright (c) 2007, John Mettraux, OpenWFE.org
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
# $Id: definitions.rb 2725 2006-06-02 13:26:32Z jmettraux $
#

#
# "made in Japan"
#
# John Mettraux at openwfe.org
#

require 'openwfe/expressions/timeout'
require 'openwfe/expressions/condition'
require 'openwfe/expressions/flowexpression'


module OpenWFE

    #
    # The "listen" expression can be viewed in two ways :
    #
    # 1)
    # It's a hook into the participant map to intercept apply or reply
    # operations on participants.
    #
    # 2)
    # It allows OpenWFE[ru] to be a bit closer to the 'ideal' process-calculus
    # world (http://en.wikipedia.org/wiki/Process_calculi)
    #
    # Anyway...
    #
    #     <listen to="alice">
    #         <subprocess ref="notify_bob" />
    #     </listen>
    #
    # Whenever a workitem is dispatched (applied) to the participant 
    # named "alice", the subprocess named "notify_bob" is triggered (once).
    #
    #     listen :to => "^channel_.*", :upon => "reply" do
    #         sequence do
    #             participant :ref => "delta"
    #             participant :ref => "echo"
    #         end
    #     end
    #
    # After the listen has been applied, the first workitem coming back from 
    # a participant whose named starts with "channel_" will trigger a sequence
    # with the participants 'delta' and 'echo'.
    #
    #     listen :to => "alpha", :where => "${f:color} == red" do
    #         participant :ref => "echo"
    #     end
    #
    # Will send a copy of the first workitem meant for participant "alpha" to 
    # participant "echo" if this workitem's color field is set to 'red'.
    #
    #     listen :to => "alpha", :once => "false" do
    #         send_email_to_stakeholders
    #     end
    #
    # This is some kind of a server : each time a workitem is dispatched to
    # participant "alpha", the subprocess (or participant) named 
    # 'send_email_to_stakeholders') will receive a copy of that workitem.
    # Use with care.
    #
    #     listen :to => "alpha", :once => "false", :timeout => "1M2w" do
    #         send_email_to_stakeholders
    #     end
    #
    # The 'listen' expression understands the 'timeout' attribute. It can thus
    # be instructed to stop listening after a certain amount of time (here,
    # after one month and two weeks).
    #
    class ListenExpression < FlowExpression
        include TimeoutMixin, ConditionMixin

        names :listen

        attr_accessor \
            :participant_regex, 
            :once, 
            :upon,
            :call_count

        def apply (workitem)

            if @children.size < 1
                reply_to_parent workitem
                return
            end

            @participant_regex = lookup_attribute :to, workitem

            raise "attribute 'to' is missing for expression 'listen'" \
                unless @participant_regex

            @once = lookup_boolean_attribute :once, workitem, true

            ldebug { "apply() @once is #{@once}" }

            @upon = lookup_attribute(:upon, workitem, "apply")[0, 5].downcase
            @upon = if @upon == "reply"
                :reply
            else
                :apply
            end

            @call_count = 0

            determine_timeout()
            reschedule(get_scheduler)

            store_itself
        end

        def cancel
            stop_observing
        end

        def reply_to_parent (workitem)
            stop_observing
            super
        end

        #
        # Only called in case of timeout.
        #
        def trigger (params)
            reply_to_parent workitem
        end

        #
        # This is the method called when a 'listenable' workitem comes in
        #
        def call (channel, *args)
            synchronize do

                upon = args[0]

                return if upon != @upon

                workitem = args[1].dup

                conditional = eval_condition(:where, workitem)
                    #
                    # note that the values if the incoming workitem (not the
                    # workitem at apply time) are used for the evaluation
                    # of the condition (if necessary).

                return if conditional == false

                return if @once and @call_count > 0

                ldebug { "call() through for #{workitem.fei.to_s}" }

                @call_count += 1
                store_itself()

                #ldebug { "call() @call_count is #{@call_count}" }

                parent = if @once
                    self
                else
                    nil
                end

                get_expression_pool.launch_template(
                    parent, @call_count - 1, @children[0], workitem, nil)
            end
        end

        #
        # Registers for timeout and start observing the participant
        # activity.
        #
        def reschedule (scheduler)

            to_reschedule(scheduler)
            start_observing
        end

        protected

            def start_observing
                get_participant_map.add_observer @participant_regex, self
            end

            def stop_observing
                get_participant_map.remove_observer self
            end
    end

end

