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

require 'openwfe/expressions/raw_prog'


module OpenWFE

    #
    # A raw representation for a process definition, programmatic
    # process definitions are turned into trees of instances of this class.
    #
    class SimpleExpRepresentation

        attr_reader \
            :name, 
            :attributes

        attr_accessor \
            :children

        def initialize (name, attributes)

            super()
            @name = name
            @attributes = attributes
            @children = []
        end

        #
        # Adds a child to this expression representation.
        #
        def << (child)
            @children << child
        end

        #
        # Always return the ProgRawExpression class.
        #
        def raw_expression_class

            ProgRawExpression
        end

        #
        # Returns an XML string, containing the equivalent process definition
        # in the classical OpenWFE process definition language.
        #
        def to_s

            doc = REXML::Document.new()
            doc << to_xml
            s = ""
            doc.write(s, 0)

            s
        end

        #
        # Returns this representation tree as an XML element (and its children).
        #
        def to_xml

            elt = REXML::Element.new(@name)

            #elt.attributes.update(@attributes)
            @attributes.each do |k, v|
                elt.attributes[k] = v
            end

            @children.each do |child|
                if child.kind_of? SimpleExpRepresentation
                    elt << child.to_xml
                else
                    elt << REXML::Text.new(child.to_s)
                end
            end

            elt
        end

        #
        # Turns an XML tree into a simple representation
        # (beware embedded XML, should do something to stop that,
        # CDATA is perhaps sufficient).
        #
        def self.from_xml (xml)

            xml = REXML::Document.new(xml) \
                if xml.is_a? String

            xml = xml.root \
                if xml.is_a? REXML::Document

            if xml.is_a? REXML::Text
                s = xml.to_s
                return s if s.strip.length > 1
                return nil
            end

            # xml element thus...

            name = xml.name

            attributes = {}

            xml.attributes.each do |k, v|
                attributes[k] = v
            end

            rep = SimpleExpRepresentation.new(name, attributes)

            xml.children.each do |c|
                r = from_xml(c)
                rep << r if r
            end

            rep
        end

        #
        # Evals the given code (string) into a SimpleExpRepresentation.
        #
        def self.from_code (code)

            ProcessDefinition.eval_ruby_process_definition code
        end

        #
        # Evals the given string a return its SimpleExpRepresentation 
        # equivalent, ready for evaluation or rendering (fluo).
        #
        def self.from_s (s)

            s = s.strip

            if s[0, 1] == "<"

                from_xml s
            else

                from_code s
            end
        end

        #
        # Returns a string containing the ruby code that generated this
        # raw representation tree.
        #
        def to_code_s (indentation = 0)

            s = ""
            tab = "    "
            ind = tab * indentation

            s << ind
            s << OpenWFE::make_safe(@name)

            sa = ""
            @attributes.each do |k, v|
                sa << ", :#{OpenWFE::to_underscore(k)} => '#{v}'"
            end
            s << sa[1..-1] if sa.length > 0

            if @children.length > 0
                s << " do\n"
                @children.each do |child|
                    if child.respond_to?(:to_code_s)
                        s << child.to_code_s(indentation + 1)
                    else
                        s << ind
                        s << tab
                        s << "'#{child.to_s}'"
                    end
                    s << "\n"
                end
                s << ind
                s << "end"
            end

            s
        end

        #
        # Turns this simple representation into an array
        # (something suitable for to_json()).
        #
        def to_a

            cs = @children.collect do |child|

                if child.respond_to?(:to_a)

                    child.to_a
                else

                    child.to_s
                end
            end

            [ @name, @attributes, cs ]
        end
    end

end

