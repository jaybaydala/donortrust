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

#
# "made in Japan"
#
# John Mettraux at openwfe.org
#

require 'openwfe/util/otime'
require 'openwfe/util/scheduler'


#
# Managing timeout for expressions like 'participant' and 'when'
#

module OpenWFE

    #
    # The timeout behaviour is implemented here, making it easy
    # to mix it in into ParticipantExpression and WhenExpression.
    #
    module TimeoutMixin
        include Schedulable

        attr_accessor \
            :timeout_at,
            :timeout_job_id
        
        #
        # Looks for the "timeout" attribute in its process definition
        # and then sets the @timeout_at field (if there is a timeout).
        #
        def determine_timeout (timeout_attname=:timeout)

            #@timeout_at = nil
            #@timeout_job_id = nil

            timeout = lookup_attribute(timeout_attname, @applied_workitem)
            return unless timeout

            timeout = OpenWFE::parse_time_string(timeout)
            @timeout_at = Time.new.to_f + timeout
        end

        #
        # Providing a default reschedule() implementation for the expressions
        # that use this mixin.
        # This default implementation just reschedules the timeout.
        #
        def reschedule (scheduler)
            to_reschedule(scheduler)
        end

        #
        # Combines a call to determine_timeout and to reschedule.
        #
        def schedule_timeout (timeout_attname=:timeout)

            determine_timeout(timeout_attname)
            to_reschedule(get_scheduler)
        end

        #
        # Overrides the parent method to make sure a potential
        # timeout schedules gets removed.
        #
        # Well... Leave that to classes that mix this in...
        # No method override in a mixin...
        #
        #def reply_to_parent (workitem)
        #    unschedule_timeout()
        #    super(workitem)
        #end

        #
        # Places a "__timed_out__" field in the workitem.
        #
        def set_timedout_flag (workitem)
            workitem.attributes["__timed_out__"] = "true"
        end

        #
        # Removes any "__timed_out__" field in the workitem.
        #
        def remove_timedout_flag (workitem)
            workitem.attributes.delete("__timed_out__")
        end

        protected

            #
            # prefixed with "to_" for easy mix in
            #
            def to_reschedule (scheduler)

                #return if @timeout_job_id
                    #
                    # already rescheduled

                return unless @timeout_at
                    #
                    # no need for a timeout

                @timeout_job_id = "timeout_#{self.fei.to_s}"

                scheduler.schedule_at(
                    @timeout_at, 
                    { :schedulable => self, 
                      :job_id => @timeout_job_id,
                      :do_timeout! => true })

                ldebug do 
                    "to_reschedule() will timeout at " +
                    "#{OpenWFE::to_iso8601_date(@timeout_at)}" +
                    " @timeout_job_id is #{@timeout_job_id}" +
                    " (oid #{object_id})"
                end

                #store_itself()
                    #
                    # done in the including expression
            end

            #
            # Unschedules the timeout
            #
            def unschedule_timeout ()

                ldebug do 
                    "unschedule_timeout() " +
                    "@timeout_job_id is #{@timeout_job_id}" +
                    " (oid #{object_id})"
                end

                #ldebug_callstack "unschedule_timeout()"

                get_scheduler.unschedule(@timeout_job_id) \
                    if @timeout_job_id
            end
    end

end

