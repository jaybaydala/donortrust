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

require 'openwfe/utils'
require 'openwfe/util/otime'
require 'openwfe/util/scheduler'
require 'openwfe/expressions/time'


module OpenWFE

    #
    # Scheduling subprocesses for repeating execution
    #
    #     <cron tab="0 9-17 * * mon-fri" name="//reminder">
    #         <send-reminder/>
    #     </cron>
    #
    # In this short process definition snippet, the subprocess "send-reminder"
    # will get triggered once per hour (minute 0) from 0900 to 1700 and
    # this, from monday to friday.
    #
    # The 'name' of the cron indicates also at which level the cron should
    # be bound. A double slash means the cron is bound at engine level (and
    # will continue until it is unbound, as long as the engine is up, if the
    # engine is a persisted one, the cron will continue when the engine
    # restarts).
    #
    # Since OpenWFEru 0.9.14, it's possible to specify 'every' instead of
    # 'tab' :
    #
    #     cron :every => "10m3s" do
    #         send_reminder
    #     end
    #
    # The subprocess 'send_reminder' will thus be triggered every ten minutes 
    # and three seconds.
    #
    class CronExpression < TimeExpression

        names :cron

        attr_accessor \
            :raw_child, :tab, :every, :name, :counter

        def apply (workitem)

            @counter = 0

            if @children.size < 1
                reply_to_parent(workitem)
                return
            end

            @applied_workitem = workitem.dup
            @applied_workitem.flow_expression_id = nil

            @tab = lookup_attribute(:tab, workitem)
            @every = lookup_attribute(:every, workitem)

            @name = lookup_attribute(:name, workitem)
            @name = fei.to_s unless @name

            @raw_child, _fei = get_expression_pool.fetch(@children[0])
            @raw_child.parent_id = nil

            clean_children()

            @children = nil

            #
            # schedule self
            
            reschedule(get_scheduler)

            #
            # store self as a variable
            # (have to do it after the reschedule, so that the schedule
            # info is stored within the variable)

            set_variable(@name, self)

            #
            # resume flow
            
            reply_to_parent(workitem)
        end

        def reply (workitem)
            # discard silently... should never get called though
        end

        #def cancel ()
        #end
            #
            # implemented in parent TimeExpression class

        #
        # This is the method called each time the scheduler triggers
        # this cron. The contained segment of process will get 
        # executed.
        #
        def trigger (params)

            ldebug { "trigger() cron : #{@fei.to_debug_s}" }

            @raw_child.application_context = @application_context

            begin

                get_expression_pool.launch_template(
                    @fei.wfid, @counter, @raw_child, @applied_workitem.dup)

                #
                # update count and store self

                @counter += 1

                #set_variable(@name, self)

            rescue
                lerror do 
                    "trigger() cron caught exception\n"+
                    OpenWFE::exception_to_s($!)
                end
            end
        end

        #
        # This method is called at the first schedule of this expression
        # or each time the engine is restarted and this expression has
        # to be rescheduled.
        #
        def reschedule (scheduler)

            #return unless @applied_workitem

            @scheduler_job_id = @name.dup

            @scheduler_job_id = "#{@fei.wfid}__#{@scheduler_job_id}" \
                unless OpenWFE::starts_with(@name, "//")

            if @tab
                get_scheduler.schedule(
                    @tab, 
                    { :schedulable => self, :job_id => @scheduler_job_id })
            else
                get_scheduler.schedule_every(
                    @every, 
                    { :schedulable => self, :job_id => @scheduler_job_id })
            end

            ldebug { "reschedule() name is   '#{@name}'" }
            ldebug { "reschedule() job id is '#{@scheduler_job_id}'" }

            #store_itself()
                #
                # done by the containing environment itself
        end
    end

end

