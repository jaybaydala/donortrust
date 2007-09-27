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


module OpenWFE

    #
    # This expression is used to launch/call a subprocess.
    #
    # For example :
    #
    #     <process-definition name="subtest0" revision="0">
    #         <sequence>
    #             <subprocess ref="sub0" a="A" b="B" c="C" />
    #             <sub0 a="A" b="B" c="C" />
    #         </sequence>
    #     
    #         <process-definition name="sub0">
    #             <print>${a}${b}${c}</print>
    #         </process-definition>
    #     
    #     </process-definition>
    #
    # It's totally OK to have URLs as referenced processes :
    #
    #     require 'openwfe/def'
    #
    #     class AnotherDefinition0 < OpenWFE::ProcessDefinition
    #         def make
    #             sequence do
    #                 participant ref => "toto"
    #                 subprocess ref => "http://company.process.server/def0.rb"
    #             end
    #         end
    #     end
    #
    # The 'subprocess' expression accepts a 'forget' attribute :
    #
    #     class AnotherDefinition1 < OpenWFE::ProcessDefinition
    #         sequence do
    #             subprocess :ref => "my_subprocess", :forget => true
    #             participant :ref => "ringo"
    #         end
    #         process-definition :name => "my_subprocess" do
    #             participant :ref => "fake steve jobs"
    #         end
    #     end
    #
    # The 'subprocess' expression accepts an 'if' (or 'unless') attribute :
    #
    #     subprocess :ref => "interview_process", :if => "${f:screened}"
    #         # will trigger the subprocess only if the field screened
    #         # contains the string 'true' or the boolean 'true'
    #
    #     interview_process :if => "${f:screened}"
    #         # idem
    #
    #     interview_process :unless => "${f:has_had_problem_with_justice_?}"
    #         # well...
    #
    class SubProcessRefExpression < FlowExpression
        include ConditionMixin

        names :subprocess


        def apply (workitem)

            conditional = eval_condition(:if, workitem, :unless)

            if conditional == false
                reply_to_parent workitem
                return
            end

            ref = lookup_ref(workitem)

            raise "'subprocess' expression misses a 'ref', 'field-ref' or 'variable-ref' attribute" unless ref

            template_uri = OpenWFE::parse_known_uri(ref)

            template = template_uri || lookup_variable(ref)

            raise "did not find any subprocess named '#{ref}'" \
                if not template

            forget = lookup_boolean_attribute(:forget, workitem)

            requester = @fei
            requester = @fei.workflow_instance_id if forget

            params = lookup_attributes(workitem)

            text = fetch_text_content(workitem, false)
            params["0"] = text if text

            #puts
            #puts " ... params are #{params.keys.join(', ')}"
            #puts " ... values are #{params.values.join(', ')}"

            get_expression_pool.launch_template(
                requester, get_next_sub_id, template, workitem, params)

            reply_to_parent(workitem) if forget
        end

        #def reply (workitem)
        #end
    end

end

