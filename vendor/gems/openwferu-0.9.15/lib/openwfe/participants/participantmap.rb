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

require 'openwfe/workitem'
require 'openwfe/service'
require 'openwfe/util/observable'
require 'openwfe/participants/participants'

include OpenWFE


module OpenWFE

    #
    # A very simple directory of participants
    #
    class ParticipantMap < Service
        include OwfeObservable

        attr_accessor \
            :participants

        def initialize (service_name, application_context)

            super

            @participants = []

            @observers = {}
        end

        #
        # Returns how many participants are currently registered here.
        #
        def size

            @participants.size
        end

        #
        # Adds a participant to this map.
        # This method is called by the engine's own register_participant()
        # method.
        #
        # The participant instance is returned by this method call
        #
        def register_participant (regex, participant=nil, &block)

            if not participant

                raise "please provide a participant instance or a block" \
                    if not block

                participant = BlockParticipant.new(block)
            end

            ldebug do 
                "register_participant() "+
                "participant class is #{participant.class}"
            end

            if participant.kind_of? Class

                ldebug { "register_participant() class #{participant}" }

                begin

                    participant = participant.new(regex, @application_context)

                rescue Exception => e
                    #ldebug do 
                    #    "register_participant() " +
                    #    "falling back to no param constructor because of \n" +
                    #    OpenWFE::exception_to_s(e)
                    #end

                    participant = participant.new
                end
            end

            unless regex.kind_of? Regexp

                regex = regex.to_s
                regex = "^" + regex unless regex[0, 1] == "^"
                regex = regex  + "$" unless regex[-1, 1] == "$"

                ldebug { "register_participant() '#{regex}'" }

                regex = Regexp.new(regex)
            end

            participant.application_context = @application_context \
                if participant.respond_to? :application_context=

            @participants << [ regex, participant ]

            participant
        end

        #
        # Looks up a participant given a participant_name.
        # Will return the first participant whose name matches.
        #
        def lookup_participant (participant_name)

            #ldebug { "lookup_participant() '#{participant_name}'" }

            participant_name = participant_name.to_s

            @participants.each do |tuple|
                return tuple[1] if tuple[0].match(participant_name)
            end

            nil
        end

        #
        # Deletes the first participant matching the given name.
        #
        def unregister_participant (participant_name)

            pos = -1
            @participants.each_with_index do |tuple, index|
                if tuple[0].match(participant_name)
                    pos = index
                    break
                end
            end
            @participants.delete(pos) if pos > -1
            
            pos > -1
        end

        #
        # Dispatches to the given participant (participant name (string) or
        # The workitem will be fed to the consume() method of that participant.
        # If it's a cancelitem and the participant has a cancel() method,
        # it will get called instead.
        #
        def dispatch (participant, participant_name, workitem)

            unless participant

                participant = lookup_participant participant_name

                raise "there is no participant named '#{participant_name}'" \
                    unless participant
            end

            workitem.participant_name = participant_name

            return cancel(participant, workitem) \
                if workitem.is_a?(CancelItem)

            onotify :dispatch, :before_consume, workitem

            workitem.dispatch_time = Time.now

            participant.consume(workitem)

            onotify :dispatch, :after_consume, workitem
        end

        #
        # The method onotify (from Osbservable) is made public so that
        # ParticipantExpression instances may notify the pmap of applies
        # and replies.
        #
        public :onotify

        protected

            #
            # Will call the cancel method of the participant if it has
            # one, or will simply discard the cancel item else.
            #
            def cancel (participant, cancel_item)

                participant.cancel(cancel_item) \
                    if participant.respond_to?(:cancel)

                onotify :dispatch, :cancel, cancel_item
                    #
                    # maybe it'd be better to specifically log that
                    # a participant has no cancel() method, but it's OK
                    # like that for now.
            end
    end

end

