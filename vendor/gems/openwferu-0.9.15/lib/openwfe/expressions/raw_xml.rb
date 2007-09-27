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

require 'rexml/document'

require 'openwfe/expressions/raw'


module OpenWFE

    #
    # Handling process definition whose representation is in XML
    # (the classical OpenWFE case).
    #
    class XmlRawExpression < RawExpression

        def initialize \
            (fei, parent_id, env_id, application_context, raw_representation)

            super(
                fei, 
                parent_id, 
                env_id, 
                application_context, 
                raw_representation)

            @raw_representation_s = raw_representation.to_s
        end

        def raw_representation

            unless @raw_representation

                @raw_representation = \
                    REXML::Document.new(@raw_representation_s).root
            end

            @raw_representation
        end

        protected

            def extract_attributes ()
                result = {}
                raw_representation.attributes.each_attribute do |a|
                    result[a.name] = a.value
                end
                return result
            end

            def extract_descriptions ()

                result = []
                raw_representation.each_child do |child|

                    next unless child.is_a?(REXML::Element)
                    next if child.name.intern != :description

                    lang = child.attributes["language"]
                    lang = child.attributes["lang"] unless lang
                    lang = "default" unless lang

                    result << [ lang, child.children[0] ]
                end
                result
            end

            def extract_children ()

                c = []
                i = 0

                raw_representation.each_child do |elt|

                    if elt.kind_of?(REXML::Element)

                        ename = elt.name.intern

                        next if ename == :param
                        next if ename == :parameter
                        next if ename == :description

                        cfei = @fei.dup

                        efei = @environment_id

                        cfei.expression_name = elt.name
                        cfei.expression_id = "#{cfei.expression_id}.#{i}"

                        rawchild = XmlRawExpression\
                            .new(cfei, @fei, efei, @application_context, elt)

                        get_expression_pool().update(rawchild)
                        c << rawchild.fei

                        i = i+1

                    elsif elt.kind_of?(REXML::Comment)

                        next

                    else

                        s = elt.to_s.strip
                        c << s if s.length > 0

                    end
                end

                c
            end

            def extract_text_children ()

                raw_representation.children.collect do |elt|

                    next if elt.is_a? REXML::Element
                    next if elt.is_a? REXML::Comment
                    s = elt.to_s.strip
                    next if s.length < 1
                    s
                end
            end

            def extract_parameters ()

                r = []
                raw_representation.children.each do |child|

                    next unless child.is_a? REXML::Element

                    cname = child.name.intern
                    next unless (cname == :param or cname == :parameter)

                    r << Parameter.new(
                        child.attributes["field"],
                        child.attributes["match"],
                        child.attributes["default"],
                        child.attributes["type"])
                end
                r
            end
    end
end

