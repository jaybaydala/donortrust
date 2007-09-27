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

require 'thread'
require 'openwfe/expressions/fe_when'


module OpenWFE

    #
    # The 'reserve' expression ensures that its nested child expression
    # executes while a reserved mutex is set.
    #
    # Thus
    #
    #     concurrence do
    #         reserve :mutex => :m0 do
    #             sequence do
    #                 participant :alpha
    #                 participant :bravo
    #             end
    #         end
    #         reserve :mutex => :m0 do
    #             participant :charly
    #         end
    #         participant :delta
    #     end
    #
    # The sequence will not but run while the participant charly is active
    # and vice versa. The participant delta is not concerned.
    #
    # The mutex is a regular variable name, thus a mutex named "//toto" could
    # be used to prevent segemnts of totally different process instances from
    # running.
    #
    class ReserveExpression < WhenExpression

        #
        # A mutex for the whole class, it's meant to prevent 'reserve'
        # from reserving a workflow mutex simultaneaously.
        #
        @@mutex = Mutex.new

        names :reserve

        attr_accessor :mutex_name

        def apply (workitem)

            if @children.size < 1
                reply_to_parent workitem
                return
            end

            @mutex_name = lookup_attribute :mutex, workitem

            super
        end

        def reply (workitem)

            @@mutex.synchronize do

                delete_variable @mutex_name \
                    if @consequence_triggered
                        #
                        # unset mutex
            end

            super workitem
        end

        protected

            def evaluate_condition

                mutex = nil

                @@mutex.synchronize do

                    mutex = lookup_variable @mutex_name
                    
                    set_variable @mutex_name, fei.to_s \
                        unless mutex
                            #
                            # reserve mutex
                end

                do_reply (mutex == nil)
            end

            def apply_consequence (workitem)

                @consequence_triggered = true

                store_itself()

                get_expression_pool.apply(@children[0], workitem)
            end
    end

end

