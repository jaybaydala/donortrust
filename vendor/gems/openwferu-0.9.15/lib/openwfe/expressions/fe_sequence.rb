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
# $Id: definitions.rb 2725 2006-06-02 13:26:32Z jmettraux $
#

#
# "made in Japan"
#
# John Mettraux at openwfe.org
#

require 'openwfe/expressions/flowexpression'


#
# The 'sequence' expression implementation
#

module OpenWFE

    #
    # This expression sequentially executes each of its children expression.
    # For a more sophisticated version of it, see the 'cursor' expression
    # (fe_cursor.rb).
    #
    class SequenceExpression < FlowExpression

        names :sequence

        attr_accessor \
            :current_child_id


        def apply (workitem)

            @current_child_id = -1

            reply workitem
        end

        def reply (workitem)

            cfei = get_to_next_child()

            unless cfei
                reply_to_parent workitem
                return
            end

            #ldebug do 
            #    "reply() self : \n#{self.to_s}\n" +
            #    "reply() next is #{@current_child_id} : #{cfei.to_debug_s}"
            #end

            store_itself()

            get_expression_pool.apply cfei, workitem
        end

        protected

            def get_to_next_child ()

                #return nil if @children.length < 1 

                @current_child_id += 1

                return nil if @current_child_id >= @children.length

                #ldebug do
                #    "get_to_next_child() " +
                #    "len: #{@children.length} / id: #{@current_child_id}"
                #end

                @children[@current_child_id..-1].each do |c|

                    return c if c.kind_of? OpenWFE::FlowExpressionId

                    @current_child_id += 1
                end

                nil 
                    #
                    # did not find any child expression
            end
    end

end

