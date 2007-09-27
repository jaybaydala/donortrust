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

require 'rexml/document'

require 'openwfe/utils'
require 'openwfe/expressions/raw'
require 'openwfe/expressions/simplerep'


module OpenWFE

    #
    # Extend this class to create a programmatic process definition.
    #
    # A short example :
    # 
    #   class MyProcessDefinition < OpenWFE::ProcessDefinition
    #       def make
    #           process_definition :name => "test1", :revision => "0" do
    #               sequence do
    #                   set :variable => "toto", :value => "nada"
    #                   print "toto:${toto}"
    #               end
    #           end
    #       end
    #   end
    #
    #   li = OpenWFE::LaunchItem.new(MyProcessDefinition)
    #   engine.launch(li)
    # 
    #
    class ProcessDefinition

        def self.metaclass; class << self; self; end; end

        attr_reader :context

        def initialize ()
            super()
            @context = Context.new
        end

        def method_missing (m, *args, &block)

            #puts "__i_method_missing >>>#{m}<<<<"

            ProcessDefinition.make_expression(
                @context, 
                OpenWFE::to_expression_name(m),
                ProcessDefinition.pack_args(args), 
                &block)
        end

        def self.method_missing (m, *args, &block)

            @ccontext = Context.new() \
                if (not @ccontext) or @ccontext.discarded?

            ProcessDefinition.make_expression(
                @ccontext, 
                OpenWFE::to_expression_name(m),
                ProcessDefinition.pack_args(args), 
                &block)
        end

        def self.make_expression (context, exp_name, params, &block)

            string_child = nil
            attributes = OpenWFE::SymbolHash.new

            #puts " ... params.class is #{params.class}"

            if params.kind_of? Hash 
                params.each do |k, v|
                    #attributes[k.to_s] = v.to_s
                    attributes[OpenWFE::symbol_to_name(k.to_s)] = v.to_s
                end
            elsif params
                string_child = params.to_s
            end

            exp = SimpleExpRepresentation.new(exp_name, attributes)

            exp.children << string_child \
                if string_child

            if context.parent_expression
                #
                # adding this new expression to its parent
                #
                context.parent_expression << exp
            else
                #
                # an orphan, a top expression
                #
                context.top_expressions << exp
            end

            return exp if not block

            context.push_parent_expression(exp)

            result = block.call

            exp.children << result \
                if result and result.kind_of? String

            context.pop_parent_expression

            exp
        end

        def do_make
            ProcessDefinition.do_make(self)
        end

        #
        # A class method for actually "making" the process 
        # segment raw representation
        #
        def ProcessDefinition.do_make (instance=nil)

            context = if @ccontext
                @ccontext.discard
                    # preventing further additions in case of reevaluation
                @ccontext
            elsif instance
                instance.make
                instance.context
            else    
                pdef = self.new
                pdef.make
                pdef.context
            end

            return context.top_expression if context.top_expression

            name, revision = 
                extract_name_and_revision(self.metaclass.to_s[8..-2])

            attributes = {}
            attributes["name"] = name
            attributes["revision"] = revision

            top_expression = SimpleExpRepresentation.new(
                "process-definition", attributes)

            top_expression.children = context.top_expressions

            top_expression
        end

        #
        # Parses the string to find the class name of the process definition
        # and returns that class (instance).
        #
        def self.extract_class (ruby_proc_def_string)

            ruby_proc_def_string.each_line do |l|

                m = l.match " *class *([a-zA-Z0-9]*) *< .*ProcessDefinition"
                return eval(m[1]) if m
            end

            nil
        end

        #
        # Turns a String containing a ProcessDefinition ...
        #
        def self.eval_ruby_process_definition (code, safety_level=2)

            o = OpenWFE::eval_safely(code, safety_level)

            o = extract_class(code) \
                if (o == nil) or o.is_a?(SimpleExpRepresentation)

            return o.do_make \
                if o.is_a?(ProcessDefinition) or o.is_a?(Class)

            o
        end

        protected

            def ProcessDefinition.pack_args (args)

                return args[0] if args.length == 1
                a = {}
                args.each_with_index do |arg, index|
                    if arg.is_a? Hash
                        a = a.merge(arg)
                        break
                    end
                    a[index.to_s] = arg
                end
                a
            end

            def ProcessDefinition.extract_name_and_revision (s)

                #puts "s is >#{s}<"

                m = Regexp.compile(".*::([^0-9_]*)_*([0-9][0-9_]*)$").match(s)
                return [ as_name(m[1]), as_revision(m[2]) ] if m

                m = Regexp.compile(".*::(.*$)").match(s)
                return [ as_name(m[1]), '0' ] if m

                [ as_name(s), '0' ]
            end

            def ProcessDefinition.as_name (s)

                return s[0..-11] if s.match(".*Definition$")
                s
            end

            def ProcessDefinition.as_revision (s)
                s.gsub("_", ".")
            end

            class Context

                attr_accessor :parent_expression, :top_expressions
                attr_reader :previous_parent_expressions

                def initialize
                    @parent_expression = nil
                    @top_expressions = []
                    @previous_parent_expressions = []
                end

                def discard
                    @discarded = true
                end
                def discarded?
                    (@discarded == true)
                end

                #
                # puts the current parent expression on top of the 'previous
                # parent expressions' stack, the current parent expression
                # is replaced with the supplied parent expression.
                #
                def push_parent_expression (exp)
                    @previous_parent_expressions.push(@parent_expression) \
                        if @parent_expression
                    @parent_expression = exp
                end

                #
                # Replaces the current parent expression with the one found
                # on the top of the previous parent expression stack (pop).
                #
                def pop_parent_expression
                    @parent_expression = @previous_parent_expressions.pop
                end

                #
                # This method returns the top expression among the 
                # top expressions...
                #
                def top_expression
                    return nil if @top_expressions.size > 1
                    exp = @top_expressions[0]
                    return exp if exp.name == "process-definition"
                    nil
                end
            end
    end

    #
    # The actual 'programmatic' raw expression.
    # Its raw_representation being an instance of SimpleExpRepresentation.
    #
    class ProgRawExpression < RawExpression

        attr_accessor \
            :raw_representation

        def initialize \
            (fei, parent_id, env_id, application_context, raw_representation)

            super(
                fei, 
                parent_id, 
                env_id, 
                application_context, 
                raw_representation)
        end

        protected 

            def extract_attributes ()
                raw_representation.attributes
            end

            def extract_descriptions ()

                result = []
                raw_representation.children.each do |child|

                    next unless child.is_a?(SimpleExpRepresentation)
                    next if child.name.intern != :description

                    lang = child.attributes[:language]
                    lang = child.attributes[:lang] unless lang
                    lang = "default" unless lang

                    result << [ lang, child.children[0] ]
                end
                result
            end

            def extract_children ()

                i = 0
                result = []
                raw_representation.children.each do |child|

                    if child.kind_of? SimpleExpRepresentation

                        cname = child.name.intern

                        next if cname == :param
                        next if cname == :parameter
                        next if cname == :description

                        cfei = @fei.dup
                        cfei.expression_name = child.name
                        cfei.expression_id = "#{cfei.expression_id}.#{i}"

                        efei = @environment_id

                        rawexp = ProgRawExpression\
                            .new(cfei, @fei, efei, @application_context, child)

                        get_expression_pool.update(rawexp)

                        i = i + 1

                        result << rawexp.fei
                    else

                        result << child
                    end
                end
                result
            end

            def extract_text_children ()
                raw_representation.children.collect do |child|
                    next if child.is_a? SimpleExpRepresentation
                    child.to_s
                end
            end

            def extract_parameters ()

                r = []
                raw_representation.children.each do |child|

                    next unless child.is_a? SimpleExpRepresentation

                    name = child.name.intern
                    next unless (name == :parameter or name == :param)

                    r << Parameter.new(
                        child.attributes[:field],
                        child.attributes[:match],
                        child.attributes[:default],
                        child.attributes[:type])
                end
                r
            end
    end

    private

        #
        # OpenWFE process definitions do use some
        # Ruby keywords... The workaround is to put an underscore
        # just before the name to 'escape' it.
        #
        # 'undo' isn't reserved by Ruby, but lets keep it in line
        # with 'do' and 'redo' that are.
        #
        KEYWORDS = [
            :if, :do, :redo, :undo, :print, :sleep, :loop, :break, :when
        ]

        #
        # Ensures the method name is not conflicting with Ruby keywords
        # and turn dashes to underscores.
        #
        def OpenWFE.make_safe (method_name)
            method_name = OpenWFE::to_underscore(method_name)
            return "_" + method_name \
                if KEYWORDS.include? eval(":"+method_name)
            method_name
        end

        def OpenWFE.to_expression_name (method_name)
            method_name = method_name.to_s
            method_name = method_name[1..-1] if method_name[0, 1] == "_"
            method_name = OpenWFE::to_dash(method_name)
            method_name
        end

end

