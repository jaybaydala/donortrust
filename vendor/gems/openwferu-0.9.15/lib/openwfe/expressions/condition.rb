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

require 'openwfe/util/safe'


module OpenWFE

    #
    # A ConditionMixin is a mixin for flow expressions like 'if' and 'break' for
    # example.
    # It allows for shorter notations like
    #
    #     <if test="${f:approved} == true"/>
    #
    # or
    #
    #     _loop do
    #         participant :graphical_designer
    #         participant :business_analyst
    #         _break :if => "${f:approved}"
    #     end
    #
    module ConditionMixin

        #
        # This is the method brought to expression classes including this
        # mixin. Easy evaluation of a conditon expressed in an attribute.
        #
        def eval_condition (attname, workitem, nattname=nil)

            positive = nil
            negative = nil

            positive = do_eval_condition(attname, workitem)
            negative = do_eval_condition(nattname, workitem) if nattname

            negative = (not negative) if negative != nil

            return positive if positive != nil

            negative
        end

        #
        # Returns nil if the cited attname (without or without 'r' prefix)
        # is not present.
        #
        # Attname may be a String or a Symbol, or an Array of String or Symbol
        # instances.
        #
        # Returns the Symbol the attribute if present.
        #
        def determine_condition_attribute (attname)

            attname = [ attname ] unless attname.is_a?(Array)

            attname.each do |aname|
                aname = aname.intern if aname.is_a?(String)
                return aname if has_attribute(aname)
                return aname if has_attribute("r" + aname.to_s)
            end

            nil
        end

        protected

            def do_eval_condition (attname, workitem)

                #attname = pick_attribute(attname) \
                #    if attname.is_a?(Array)

                conditional = lookup_attribute(attname, workitem)
                rconditional = lookup_attribute("r"+attname.to_s, workitem)

                return do_eval(rconditional, workitem) \
                    if rconditional and not conditional

                return nil \
                    unless conditional

                ldebug { "do_eval_condition() 0 for  '#{conditional}'" }

                conditional = from_xml conditional

                ldebug { "do_eval_condition() 1 for  '#{conditional}'" }

                begin
                    return to_boolean(do_eval(conditional, workitem))
                rescue Exception => e
                    # probably needs some quoting...
                end

                conditional = do_quote(conditional)

                ldebug { "do_eval_condition() 2 for  '#{conditional}'" }

                to_boolean(do_eval(conditional, workitem))
            end

        private

            #
            # Returns true if result is the "true" String or the true 
            # boolean value. Returns false else.
            #
            def to_boolean (result)
                ldebug { "to_boolean() result is  '#{result}'" }
                (result == "true" or result == true)
            end

            def from_xml (string)

                s = string
                s.gsub!("&gt;", ">")
                s.gsub!("&lt;", "<")
                s
            end

            #
            # Quotes the given string so that it can easily get evaluated
            # as Ruby code (a string comparison actually).
            #
            def do_quote (string)

                op = find_operator string

                return '"' + string + '"' unless op

                op, i = op

                s = '"'
                s << string[0..i-1].strip
                s << '" '
                s << string[i, op.length]
                s << ' "'
                s << string[i+op.length..-1].strip
                s << '"'
                s
            end

            #
            # Returns the operator and its index (position) in the string.
            # Returns nil if not operator was found in the string.
            #
            def find_operator (string)
                [ "==", "!=", "<=", ">=", "<", ">" ].each do |op|
                    i = string.index op
                    next unless i
                    return [ op, i ]
                end
                nil
            end

            #
            # Runs the given given within an instance_eval() at a $SAFE
            # level of 3.
            #
            def do_eval (s, workitem)

                #OpenWFE::instance_eval_safely(self, s, 3)

                wi = workitem
                fe = self
                OpenWFE::eval_safely(s, 3, binding())
            end
    end

end

