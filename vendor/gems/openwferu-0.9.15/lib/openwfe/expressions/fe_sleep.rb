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
require 'openwfe/expressions/time'


#
# just the 'sleep' expression
#

module OpenWFE

    #
    # The 'sleep' expression expects one attribute, either 'for', either
    # 'until'.
    #
    #     <sequence>
    #         <sleep for="10m12s" />
    #         <participant ref="alpha" />
    #     </sequence>
    #
    # will wait for 10 minutes and 12 seconds before sending a workitem
    # to participant 'alpha'.
    #
    class SleepExpression < TimeExpression

        names :sleep

        attr_accessor \
            :awakening_time

        def apply (workitem)

            sfor = lookup_attribute(:for, workitem)
            suntil = lookup_attribute(:until, workitem)

            sfor = fetch_text_content(workitem) \
                if sfor == nil and suntil == nil

            #ldebug { "apply() sfor is '#{sfor}'" }
            #ldebug { "apply() suntil is '#{suntil}'" }

            tuntil = nil

            if suntil
                tuntil = suntil
            elsif sfor
                tfor = OpenWFE::parse_time_string(sfor)
                #ldebug { "apply() tfor is '#{tfor}'" }
                tuntil = Time.new.to_f + tfor
            end

            #ldebug { "apply() tuntil is '#{tuntil}'" }

            if not tuntil
                reply_to_parent(workitem)
                return
            end

            @awakening_time = tuntil
            @applied_workitem = workitem.dup

            reschedule(get_scheduler)
        end

        #def reply (workitem)
        #end

        #
        # This is the method called by the Scheduler instance attached to
        # the workflow engine when the 'sleep' of this expression is 
        # over
        #
        def trigger (params)
            ldebug do 
                "trigger() #{@fei.to_debug_s} waking up (#{Time.new.to_f}) "+
                "(scheduler #{get_scheduler.object_id})"
            end
            reply_to_parent(@applied_workitem)
        end

        #
        # [Re]schedules this expression, effectively registering it within
        # the scheduler.
        # This method is called when the expression is applied and each
        # time the owning engine restarts.
        #
        def reschedule (scheduler)

            return unless @awakening_time

            ldebug do 
                "[re]schedule() " + 
                "will sleep until '#{@awakening_time}' " +
                "(#{OpenWFE::to_iso8601_date(@awakening_time)})"
            end

            @scheduler_job_id = "sleep_#{self.fei.to_s}"
            
            scheduler.schedule_at(
                @awakening_time,
                { :schedulable => self, :job_id => @scheduler_job_id })

            ldebug do 
                "[re]schedule() @scheduler_job_id is '#{@scheduler_job_id}' "+
                " (scheduler #{scheduler.object_id})"
            end

            store_itself()
        end
    end

end

