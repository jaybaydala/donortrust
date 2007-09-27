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

require 'openwfe/exceptions'
require 'openwfe/expressions/flowexpression'
require 'openwfe/rudefinitions'


module OpenWFE

    #
    # An 'abstract' class storing bits (trees) of process definitions just
    # parsed. Upon application (apply()) these raw expressions get turned
    # into real expressions.
    # The first and classical extension of this class is XmlRawExpression.
    #
    class RawExpression < FlowExpression

        def initialize (
            fei, parent_id, env_id, application_context, raw_representation)

            super(fei, parent_id, env_id, application_context, nil)

            @raw_representation = raw_representation

            #new_environment() if not @environment_id
                #
                # now done in the launch methods of the expression pool
        end

        def instantiate_real_expression (
            workitem, exp_name=nil, exp_class=nil, attributes=nil)

            exp_name = expression_name() unless exp_name
            exp_class = expression_class() unless exp_class

            raise "unknown expression '#{exp_name}'" \
                unless exp_class

            #ldebug do 
            #    "instantiate_real_expression() exp_class is #{exp_class}"
            #end

            attributes = extract_attributes() unless attributes

            expression = exp_class.new(
                @fei, 
                @parent_id, 
                @environment_id, 
                @application_context, 
                attributes)

            consider_tag(workitem, expression)
            
            handle_descriptions()

            expression.children = extract_children()

            expression.store_itself()

            expression
        end

        #
        # When a raw expression is applied, it gets turned into the
        # real expression which then gets applied.
        #
        def apply (workitem)

            exp_name, exp_class, attributes = determine_real_expression

            expression = instantiate_real_expression(
                workitem, exp_name, exp_class, attributes)

            #expression.apply_time = OpenWFE::now()
                #
                # This method is extremely costly, now avoiding it

            expression.apply_time = Time.now

            expression.apply workitem
        end

        #
        # This method is called by the expression pool when it is about
        # to launch a process, it will interpret the 'parameter' statements
        # in the process definition and raise an exception if the requirements
        # are not met.
        #
        def check_parameters (workitem)

            extract_parameters.each do |param|
                param.check(workitem)
            end
        end

        #def reply (workitem)
        # no implementation necessary
        #end

        def is_definition? ()
            get_expression_map.is_definition?(expression_name())
        end

        def expression_class ()
            get_expression_map.get_class(expression_name())
        end

        def definition_name ()
            raw_representation.attributes['name'].to_s
        end

        def expression_name ()
            raw_representation.name
        end

        #
        # Forces the raw expression to load the attributes and set them
        # in its @attributes instance variable.
        # Currently only used by FilterDefinitionExpression.
        #
        def load_attributes
            @attributes = extract_attributes()
        end
        
        protected

            #
            # looks up a participant in the participant map, considers
            # "my-participant" and "my_participant" as the same
            # (by doing two lookups).
            #
            def lookup_participant (name)

                p = get_participant_map.lookup_participant(name)

                unless p
                    name = OpenWFE::to_underscore(name)
                    p = get_participant_map.lookup_participant(name)
                end

                if p 
                    name
                else
                    nil
                end
            end

            #
            # Determines if this raw expression points to a classical 
            # expression, a participant or a subprocess, or nothing at all...
            #
            def determine_real_expression ()

                exp_name = expression_name()

                exp_class = expression_class()
                attributes = nil

                var_value = lookup_variable(exp_name)

                var_value = exp_name if (not exp_class and not var_value)

                if var_value
                    attributes = extract_attributes()
                end

                if var_value.is_a?(String)

                    participant_name = lookup_participant(var_value)

                    if participant_name
                        exp_name = participant_name
                        exp_class = OpenWFE::ParticipantExpression
                        attributes['ref'] = participant_name
                    end

                elsif var_value.is_a?(OpenWFE::FlowExpressionId)

                    exp_class = OpenWFE::SubProcessRefExpression
                    attributes['ref'] = exp_name
                end

                [ exp_name, exp_class, attributes ]
            end

            #
            # Takes care of extracting the process definition descriptions
            # if any and to set the description variables accordingly.
            #
            def handle_descriptions

                default = false

                ds = extract_descriptions

                ds.each do |k, description|
                    vname = if k == "default"
                        default = true
                        "description"
                    else
                        "description__#{k}"
                    end
                    set_variable vname, description
                end

                return if ds.length < 1

                set_variable "description", ds[0][1] \
                    unless default
            end

            def extract_attributes ()
                raise NotImplementedError.new("'abstract method' sorry")
            end
            def extract_children ()
                raise NotImplementedError.new("'abstract method' sorry")
            end
            def extract_descriptions ()
                raise NotImplementedError.new("'abstract method' sorry")
            end
            def extract_parameters ()
                raise NotImplementedError.new("'abstract method' sorry")
            end
            def extract_text_children ()
                raise NotImplementedError.new("'abstract method' sorry")
            end

            #
            # Expressions can get tagged. Tagged expressions can easily
            # be cancelled (undone) or redone.
            #
            def consider_tag (workitem, new_expression)

                tagname = new_expression.lookup_attribute(:tag, workitem)

                return unless tagname

                ldebug { "consider_tag() tag is '#{tagname}'" }

                set_variable(tagname, Tag.new(self, workitem))
                    #
                    # keep copy of raw expression and workitem as applied

                new_expression.attributes["tag"] = tagname
                    #
                    # making sure that the value of tag doesn't change anymore
            end

            #
            # A small class wrapping a tag (a raw expression and the workitem
            # it received at apply time.
            #
            class Tag

                attr_reader \
                    :raw_expression,
                    :workitem

                def flow_expression_id
                    @raw_expression.fei
                end
                alias :fei :flow_expression_id

                def initialize (raw_expression, workitem)

                    @raw_expression = raw_expression.dup
                    @workitem = workitem.dup
                end
            end

            #
            # Encapsulating 
            #     <parameter field="x" default="y" type="z" match="m" />
            #
            class Parameter

                def initialize (field, match, default, type)

                    @field = field
                    @match = match
                    @default = default
                    @type = type
                end

                #
                # Will raise an exception if this param requirement is not
                # met by the workitem.
                #
                def check (workitem)

                    unless @field
                        raise \
                            OpenWFE::ParameterException,
                            "'parameter'/'param' without a 'field' attribute"
                    end

                    field_value = workitem.attributes[@field]
                    field_value = @default unless field_value

                    unless field_value
                        raise \
                            OpenWFE::ParameterException, 
                            "field '#{@field}' is missing" \
                    end

                    check_match(field_value)

                    enforce_type(workitem, field_value)
                end

                protected

                    #
                    # Will raise an exception if it cannot coerce the type
                    # of the value to the one desired.
                    #
                    def enforce_type (workitem, value)

                        value = if not @type
                            value
                        elsif @type == "string"
                            value.to_s
                        elsif @type == "int" or @type == "integer"
                            Integer(value)
                        elsif @type == "float"
                            Float(value)
                        else
                            raise 
                                "unknown type '#{@type}' for field '#{@field}'"
                        end

                        workitem.attributes[@field] = value
                    end

                    def check_match (value)

                        return unless @match

                        unless value.to_s.match(@match)
                            raise \
                                OpenWFE::ParameterException,
                                "value of field '#{@field}' doesn't match"
                        end
                    end
            end
    end

end

