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
require 'openwfe/util/safe'

#
# 'dollar notation' implementation in Ruby
#

module OpenWFE

    DSUB_SAFETY_LEVEL = 3
        #
        # Ruby code ${ruby:...} will be evaluated with this
        # safety level.
        # (see http://www.rubycentral.com/book/taint.html )

    #
    # Performs 'dollar substitution' on a piece of text with a given 
    # dictionary.
    #
    def OpenWFE.dsub (text, dict)

        #puts "### text is >#{text}<"
        #puts "### dict is of class #{dict.class.name}"

        #return nil unless text

        j = text.index("}")

        return text if not j

        t = text[0, j]

        i = t.rindex("${")
        ii = t.rindex("\\${")

        #puts "i  is #{i}"
        #puts "ii is #{ii}"

        return text if not i

        return unescape(text) if (i) and (i != 0) and (ii == i-1)
            #
            # found "\${"

        key = text[i+2..j-1]

        #puts "### key is '#{key}'"

        value = dict[key]

        #puts "### value 0 is '#{value}'"

        if value
            value = value.to_s 
        else
            if dict.has_key? key
                value = "false"
            else
                value = ""
            end
        end

        #puts "### value 1 is '#{value}'"

        #puts "pre is  >#{text[0..i-1]}<"
        #puts "post is >#{text[j+1..-1]}<"

        pre = ""
        if i > 0 
            pre = text[0..i-1]
        end

        return dsub("#{pre}#{value}#{text[j+1..-1]}", dict)
    end

    def OpenWFE.unescape (text)
        return text.gsub("\\\\\\$\\{", "\\${")
    end

    #
    # Performs 'dollar substitution' on a piece of text with as input
    # a flow expression and a workitem (fields and variables).
    #
    def OpenWFE.dosub (text, flow_expression, workitem)
        return dsub(text, FlowDict.new(flow_expression, workitem))
    end

    class FlowDict < Hash

        def initialize (flow_expression, workitem)
            @flow_expression = flow_expression
            @workitem = workitem
        end

        def [] (key)
            p, k = extract_prefix(key)

            #puts "### p, k is '#{p}', '#{k}'"

            return '' if k == ''

            return @workitem.lookup_attribute(k) if p == 'f'

            if p == 'v'
                return '' unless @flow_expression
                return @flow_expression.lookup_variable(k) 
            end

            return call_function(k) if p == 'c'
            return call_ruby(k) if p == 'r'
            # TODO : implement constant lookup

            return @workitem.lookup_attribute(key)
        end

        def has_key? (key)
            p, k = extract_prefix(key)

            return false if k == ''

            return @workitem.has_attribute?(k) if p == 'f'

            if p == 'v'
                return false unless @flow_expression
                return (@flow_expression.lookup_variable(k) != nil)
            end

            return true if p == 'c'
            return true if p == 'r'
            # TODO : implement constant lookup

            return @workitem.has_attribute?(key)
        end

        protected

            def extract_prefix (key)
                i = key.index(':')
                return 'v', key if not i
                return key[0..0], key[i+1..-1]
            end

            def call_function (function_name)
                #"function '#{function_name}' is not implemented"
                "functions are not yet implemented"
            end

            def call_ruby (ruby_code)

                if @flow_expression
                    return "" \
                        if @flow_expression.ac[:ruby_eval_allowed] != true
                end

                #binding = nil
                #binding = @flow_expression.get_binding if @flow_expression
                #eval(ruby_code, binding).to_s

                wi = @workitem
                workitem = @workitem

                fexp = nil
                flow_expression = nil
                fei = nil

                if @flow_expression
                    fexp = @flow_expression
                    flow_expression = @flow_expression
                    fei = @flow_expression.fei
                end
                    #
                    # some simple notations made available to ${ruby:...}
                    # notations

                #eval(ruby_code, binding).to_s
                #eval(ruby_code).to_s

                OpenWFE::eval_safely(
                    ruby_code, DSUB_SAFETY_LEVEL, binding()).to_s
            end
    end

end

