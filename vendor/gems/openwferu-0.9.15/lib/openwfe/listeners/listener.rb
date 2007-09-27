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

require 'openwfe/logging'
require 'openwfe/workitem'
require 'openwfe/contextual'


#
# some base listener implementation
#
module OpenWFE

    #
    # The only thing this mixin module provides is a #reply_to_engine method.
    # The details on how the workitems arrive are left to the implementations.
    #
    module WorkItemListener
        include Contextual, Logging, OwfeServiceLocator

        @accept_launchitems = true

        #
        # Determines if the listener should accept or not incoming
        # launchitems.
        #
        def accept_launchitems= (b)
            raise ArgumentError.new("boolean value expected") \
                if b != true and b != false
            @accept_launchitems = b
        end

        #
        # Returns true if the listener accepts workitems.
        # If launchitems are not accepted, the listener will simply
        # discard them (with a log info message).
        #
        def accept_launchitems?
            @accept_launchitems
        end

        protected

            #
            # Simply considers the object as a workitem and feeds it to the 
            # engine.
            #
            def handle_object (object)

                return nil if filter_out_launchitems(object)

                get_engine.reply(object)
            end

            #
            # Returns true if the listener doesn't accept LaunchItem instances
            # and the item is one of them.
            #
            def filter_out_launchitems (item)

                return false unless item.is_a? OpenWFE::LaunchItem

                return (not accept_launchitems?)
            end
    end

end

