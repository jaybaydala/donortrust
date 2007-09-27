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

require 'openwfe/util/otime'
require 'openwfe/util/scheduler'
require 'openwfe/expressions/timeout'


module OpenWFE

    #
    # A parent class for CronExpression and SleepExpression, is never
    # used directly.
    # It contains a simple get_scheduler() method simplifying the scheduler
    # localization for <sleep/> and <cron/>.
    #
    class TimeExpression < FlowExpression
        include Schedulable

        attr_accessor \
            :applied_workitem,
            :scheduler_job_id

        #
        # Makes sure to cancel any scheduler job associated with this
        # expression
        #
        def cancel ()
            synchronize do

                ldebug { "cancel()..." }

                unschedule()

                super()

                @applied_workitem
            end
        end

        #
        # If the expression has been scheduled, a call to this method
        # will make sure it's unscheduled (removed from the scheduler).
        #
        def unschedule ()

            ldebug { "unschedule() @scheduler_job_id is #{@scheduler_job_id}" }

            get_scheduler.unschedule(@scheduler_job_id) \
                if @scheduler_job_id
        end
    end

    #
    # A parent class for WhenExpression and WaitExpression.
    #
    # All the code for managing waiting for something to occur is 
    # concentrated here.
    #
    class WaitingExpression < TimeExpression
        include ConditionMixin, TimeoutMixin

        attr_accessor :frequency

        #
        # By default, classes extending this class do poll for their
        # condition every 10 seconds.
        #
        DEFAULT_FREQUENCY = "10s"

        #
        # Classes extending this WaitingExpression have a 'conditions' class
        # method (like 'attr_accessor').
        #
        def self.conditions (*attnames)
            attnames = attnames.collect do |n|
                n.to_s.intern
            end
            meta_def :condition_attributes do
                attnames
            end
        end

        def apply (workitem)

            remove_timedout_flag(workitem)

            @applied_workitem = workitem.dup

            @frequency = 
                lookup_attribute(:frequency, workitem, DEFAULT_FREQUENCY)
            @frequency = 
                OpenWFE::parse_time_string(@frequency)

            determine_timeout()

            store_itself()

            trigger()
        end

        def reply (workitem)

            result = workitem.get_result

            if result
                apply_consequence(workitem)
            else
                reschedule(get_scheduler)
            end
        end

        def cancel ()

            to_unschedule()
            super()
        end

        def trigger (params={})

            ldebug { "trigger() #{@fei.to_debug_s} params is #{params}" }

            if params[:do_timeout!]
                #
                # do timeout...
                #
                set_timedout_flag @applied_workitem
                reply_to_parent @applied_workitem
                return
            end

            @scheduler_job_id = nil

            evaluate_condition()
        end

        def reschedule (scheduler)

            @scheduler_job_id = "waiting_#{fei.to_s}"

            scheduler.schedule_in(
                @frequency, 
                { :schedulable => self, :job_id => @scheduler_job_id })

            ldebug { "reschedule() @scheduler_job_id is #{@scheduler_job_id}" }

            to_reschedule(scheduler)
        end

        def reply_to_parent (workitem)

            unschedule()
            unschedule_timeout()

            super(workitem)
        end

        protected

            #
            # The code for the condition evalution is here.
            #
            # This method is overriden by the WhenExpression.
            #
            def evaluate_condition

                condition_attribute = determine_condition_attribute(
                    self.class.condition_attributes)

                if condition_attribute

                    c = eval_condition(condition_attribute, @applied_workitem)

                    do_reply c
                    return
                end

                # else, condition is nested as a child

                if @children.size < 1
                    #
                    # no condition attribute and no child attribute,
                    # simply reply to parent
                    #
                    reply_to_parent @applied_workitem
                    return
                end

                # trigger the first child (the condition child)

                get_expression_pool.launch_template(
                    self, @condition_sub_id, @children[0], @applied_workitem)
            end

            #
            # Used when replying to self after an attribute condition
            # got evaluated
            #
            def do_reply (result)

                @applied_workitem.set_result result
                reply @applied_workitem
            end

            #
            # This method is overriden by WhenExpression. WaitExpression
            # doesn't override it.
            # This default implementation simply directly replies to
            # the parent expression.
            #
            def apply_consequence (workitem)

                reply_to_parent workitem
            end
    end

end

