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

require 'openwfe/util/safe'
require 'openwfe/expressions/flowexpression'


module OpenWFE

    class PrintExpression < FlowExpression

        names :print

        #
        # apply / reply

        def apply (workitem)

            escape = lookup_boolean_attribute('escape', workitem, false)

            text = fetch_text_content(workitem, escape)
            text << "\n"

            tracer = @application_context['__tracer']

            if tracer
                tracer << text
            else
                puts text
            end

            reply_to_parent(workitem)
        end

        #def reply (workitem)
        #end

    end

    #
    # <reval/>
    #
    # Evals some Ruby code contained within the process definition 
    # or within the workitem.
    # 
    # The code is evaluated at a SAFE level of 3.
    #
    # If the :ruby_eval_allowed isn't set to true 
    # (<tt>engine.application_context[:ruby_eval_allowed] = true</tt>), this
    # expression will throw an exception at apply.
    #
    # some examples :
    #
    #     <reval>
    #         workitem.customer_name = "doug"
    #         # or for short 
    #         wi.customer_address = "midtown 21_21 design"
    #     </reval>
    #
    # in a Ruby process definition :
    #
    #     sequence do
    #         _set :field => "customer" do
    #             reval """
    #                 {
    #                     :name => "Cheezburger",
    #                     :age => 34,
    #                     :comment => "I can haz ?",
    #                     :timestamp => Time.now.to_s
    #                 }
    #             """
    #         end
    #     end
    #
    # Don't embed too much Ruby into your process definitions, it might
    # hurt...
    #
    class RevalExpression < FlowExpression

        names :reval

        #
        # See for an explanation on Ruby safety levels :
        # http://www.rubycentral.com/book/taint.html
        #
        SAFETY_LEVEL = 3

        def apply (workitem)

            raise "evaluation of ruby code is not allowed" \
                if @application_context[:ruby_eval_allowed] != true

            escape = lookup_boolean_attribute('escape', workitem, false)

            code = lookup_vf_attribute(workitem, 'code')

            code = fetch_text_content(workitem, escape) \
                unless code

            code = code.to_s

            wi = workitem

            result = OpenWFE::eval_safely code, SAFETY_LEVEL, binding()

            workitem.set_result(result) \
                if result != nil  # 'false' is a valid result

            reply_to_parent workitem
        end
    end

end

