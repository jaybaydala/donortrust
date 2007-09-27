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

require 'openwfe/workitem'
require 'openwfe/flowexpressionid'
require 'openwfe/expressions/flowexpression'


#
# expressions like 'set' and 'unset' and their utility methods
#

module OpenWFE

    #
    # A parent class for the 'equals' expression.
    #
    class ComparisonExpression < FlowExpression

        def apply (workitem)

            #
            # preparing for children handling... later...
            #

            reply workitem
        end

        def reply (workitem)

            value_a, value_b = lookup_values workitem

            result = compare value_a, value_b

            ldebug { "apply() result is '#{result}'  #{@fei.to_debug_s}" }

            workitem.set_result result

            reply_to_parent workitem
        end

        protected

            #
            # The bulk job of looking up the values to compare
            #
            def lookup_values (workitem)

                value_a = lookup_value workitem
                value_b = lookup_value workitem, 'other'

                value_c = lookup_variable_or_field workitem

                if not value_a and value_b
                    value_a = value_c
                elsif value_a and not value_b
                    value_b = value_c
                end

                [ value_a, value_b ]
            end

            #
            # Returns the value pointed at by the variable attribute or by
            # the field attribute, in that order.
            #
            def lookup_variable_or_field (workitem)

                v = lookup_attribute :variable, workitem
                return lookup_variable(v) if v

                f = lookup_attribute :field, workitem
                return workitem.attributes[f] if f

                nil
            end

            #
            # This method has to be implemented by extending classes
            #
            def compare (a, b)

                raise "not yet implemented : '#{@fei.expressionName}'"
            end
    end

    #
    #     <equals/>
    #
    class EqualsExpression < ComparisonExpression

        names :equals

        protected

            def compare (a, b)
                #ldebug { "compare()  #{fei.to_debug_s}" }
                #ldebug { "compare() '#{a}' == '#{b}'" }
                return a == b
            end
    end

    #
    # This expression class actually implements 'defined' and 'undefined'.
    #
    class DefinedExpression < FlowExpression

        names :defined, :undefined

        def apply (workitem)

            fname = lookup_attribute(:field_value, workitem)
            fname = lookup_attribute(:field, workitem) unless fname

            fmatch = lookup_attribute(:field_match, workitem)

            vname = lookup_attribute(:variable_value, workitem)
            vname = lookup_attribute(:variable, workitem) unless vname

            result = if fname
                workitem.has_attribute? fname
            elsif vname
                lookup_variable(vname) != nil
            elsif fmatch
                field_match?(workitem, fmatch)
            else
                false
            end

            result = ( ! result) if result != nil \
                if fei.expression_name == 'undefined'

            workitem.set_result result

            reply_to_parent workitem
        end

        protected

            def field_match? (workitem, regex)

                workitem.attributes.each do |k, v|

                    return true if k.match(regex)
                end

                false
            end
    end

end

