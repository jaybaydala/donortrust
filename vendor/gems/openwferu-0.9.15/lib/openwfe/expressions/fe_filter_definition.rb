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
# $Id: definitions.rb 2725 2006-06-02 13:26:32Z jmettraux $
#

#
# "made in Japan"
#
# John Mettraux at openwfe.org
#

require 'openwfe/filterdef'


module OpenWFE

    #
    # This expression binds a filter definition into a variable.
    #
    #     class TestFilter48a0 < ProcessDefinition
    #         sequence do
    #
    #             set :field => "readable", :value => "bible"
    #             set :field => "writable", :value => "sand"
    #             set :field => "randw", :value => "notebook"
    #             set :field => "hidden", :value => "playboy"
    #
    #             alice
    #
    #             filter :name => "filter0" do
    #                 sequence do
    #                     bob
    #                     charly
    #                 end
    #             end
    #
    #             doug
    #         end
    #
    #         filter_definition :name => "filter0" do
    #             field :regex => "readable", :permissions => "r"
    #             field :regex => "writable", :permissions => "w"
    #             field :regex => "randw", :permissions => "rw"
    #             field :regex => "hidden", :permissions => ""
    #         end
    #     end
    #
    # In that example, the filter definition is done for filter 'filter0'.
    #
    # A filter definition accepts 4 attributes :
    #
    # * 'name' - simply naming the filter, the filter is then bound as a variable. This is the only mandatory attribute.
    #
    # * 'closed' - by default, set to 'false'. A closed filter will not allow modifications to unspecified fields.
    #
    # * 'add' - by default, set to 'true'. When true, this filter accepts adding new fields to the filtered workitem.
    #
    # * 'remove' - by default, set to 'true'. When true, this filter accepts removing fields to the filtered workitem.
    #
    #
    # Inside of the process definition, fields are identified via regular 
    # expressions ('regex'), a 'permissions' string is then expected with four 
    # possible values "rw", "w", "r" and "".
    #
    class FilterDefinitionExpression < FlowExpression

        is_definition

        names :filter_definition


        #
        # Will build the filter and bind it as a variable.
        #
        def apply (workitem)

            filter = build_filter workitem
            filter_name = lookup_attribute :name, workitem

            set_variable filter_name, filter \
                if filter_name and filter

            reply_to_parent workitem
        end

        protected

            #
            # Builds the filter (as described in the process definition) 
            # and returns it.
            #
            def build_filter (workitem)

                filter = FilterDefinition.new

                # filter attributes

                type = lookup_downcase_attribute :type, workitem
                closed = lookup_downcase_attribute :closed, workitem

                filter.closed = (type == "closed" or closed == "true")

                add = lookup_downcase_attribute :add, workitem
                remove = lookup_downcase_attribute :remove, workitem

                filter.add_allowed = (add == "true")
                filter.remove_allowed = (remove == "true")

                # field by field

                @children.each do |fei|

                    rawexp = get_expression_pool.fetch_expression fei
                    get_expression_pool.remove fei

                    add_field filter, rawexp, workitem
                end

                filter
            end

            #
            # builds and add a field (a line) of the filter.
            #
            def add_field (filter, rawexp, workitem)

                rawexp.load_attributes

                regex = rawexp.lookup_attribute :regex, workitem
                regex = rawexp.lookup_attribute :name, workitem unless regex

                permissions = 
                    rawexp.lookup_downcase_attribute :permissions, workitem

                filter.add_field regex, permissions
            end
    end

end

