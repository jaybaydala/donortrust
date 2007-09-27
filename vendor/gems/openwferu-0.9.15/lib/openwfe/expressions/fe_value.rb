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
require 'openwfe/flowexpressionid'
require 'openwfe/expressions/flowexpression'


module OpenWFE

    #
    # A small mixin providing value for looking up the attributes
    # variable/var/v and field/fld/f.
    #
    module ValueMixin

        def lookup_variable_attribute (workitem)

            lookup [ "variable", "var", "v" ], workitem
        end

        def lookup_field_attribute (workitem)

            lookup [ "field", "fld", "f" ], workitem
        end

        private

            def lookup (name_array, workitem)

                name_array.each do |n|
                    v = lookup_attribute(n, workitem)
                    return v if v
                end

                nil
            end
    end

    #
    # The 'set' expression is used to set the value of a (process) variable or
    # a (workitem) field.
    #
    #     <set field="price" value="CHF 12.00" />
    #     <set variable="/stage" value="3" />
    #     <set variable="/stage" field-value="f_stage" />
    #     <set field="stamp" value="${r:Time.now.to_i}" />
    #
    # (Notice the usage of the dollar notation in the last exemple).
    #
    # 'set' expressions may be placed outside of a process-definition body,
    # they will be evaluated sequentially before the body gets applied 
    # (executed).
    #
    # Since OpenWFEru 0.9.14, shorter attributes are OK :
    #
    #     <set f="price" val="CHF 12.00" />
    #     <set v="/stage" val="3" />
    #     <set v="/stage" field-val="f_stage" />
    #     <set f="stamp" val="${r:Time.now.to_i}" />
    #
    #     set :f => "price", :val => "USD 12.50"
    #     set :v => "toto", :val => "elvis"
    #
    class SetValueExpression < FlowExpression
        include ValueMixin

        is_definition

        names :set


        def apply (workitem)

            if @children.length < 1
                workitem.attributes[FIELD_RESULT] = lookup_value(workitem)
                reply(workitem)
                return
            end

            child = @children[0]

            if child.kind_of? OpenWFE::FlowExpressionId
                handle_child(child, workitem)
                return
            end

            #workitem.attributes[FIELD_RESULT] = child.to_s
            workitem.attributes[FIELD_RESULT] = fetch_text_content(workitem)

            reply(workitem)
        end

        def reply (workitem)

            vkey = lookup_variable_attribute(workitem)
            fkey = lookup_field_attribute(workitem)

            value = workitem.attributes[FIELD_RESULT]

            #puts "value is '#{value}'"

            if vkey
                set_variable vkey, value
            elsif fkey
                workitem.attributes[fkey] = value
            else
                raise "'variable' or 'field' attribute missing from 'set' expression"
            end

            reply_to_parent(workitem)
        end

        protected 

            def handle_child (child, workitem)

                child, _fei = get_expression_pool().fetch(child)

                if child.is_definition?
                    fei = get_expression_pool().evaluate(child, workitem)
                    workitem.attributes[FIELD_RESULT] = fei
                    reply(workitem)
                else
                    get_expression_pool().apply(child, workitem)
                end
            end
    end

    #
    # 'unset' removes a field or a variable.
    #
    #     unset :field => "price"
    #     unset :variable => "eval_result"
    #
    class UnsetValueExpression < FlowExpression
        include ValueMixin

        names :unset

        def apply (workitem)

            vkey = lookup_variable_attribute(workitem)
            fkey = lookup_field_attribute(workitem)

            if vkey
                delete_variable(vkey)
            elsif fkey
                workitem.attributes.delete(fkey)
            else
                raise "attribute 'variable' or 'field' is missing for 'unset' expression"
            end

            reply_to_parent(workitem)
        end
    end

end

