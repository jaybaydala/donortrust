#
#--
# Copyright (c) 2005-2007, John Mettraux, OpenWFE.org
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
# "hecho en Costa Rica"
# enhanced in Japan
#
# john.mettraux@openwfe.org
#


module OpenWFE

    #
    # A FlowExpressionId is a unique identifier for a FlowExpression (an atomic
    # piece of a process instance).
    # 
    # As workitems move through a workflow among the expressions and are emitted
    # outside of the business process engine via 'participant expressions', these 
    # workitems are identified by the FlowExpressionId of the participant
    # expression that pushed them out (and is waiting for them to come back).
    #
    class FlowExpressionId

        FIELDS = [ 
            :owfe_version, 
            :engine_id, 
            :initial_engine_id,
            :workflow_definition_url,
            :workflow_definition_name,
            :workflow_definition_revision,
            :workflow_instance_id,
            :expression_name,
            :expression_id
        ]

        FIELDS.each { |f| attr_accessor f }

        #
        # A shortcut for fei.workflow_instance_id.
        # There's also fei.parent_wfid.
        #
        alias :wfid :workflow_instance_id
        alias :wfid= :workflow_instance_id=
        alias :expid :expression_id
        alias :expid= :expression_id=

        alias :expname :expression_name
        alias :wfname :workflow_definition_name
        alias :wfrevision :workflow_definition_revision

        #
        # Overrides the classical to_s()
        #
        def to_s ()
            "(fei #{@owfe_version} #{@engine_id}/#{@initial_engine_id} #{@workflow_definition_url} #{@workflow_definition_name} #{@workflow_definition_revision} #{@workflow_instance_id} #{@expression_name} #{@expression_id})"
        end

        #
        # Returns a hash version of this FlowExpressionId instance.
        #
        def to_h ()

            h = {}
            FIELDS.each { |f| h[f] = instance_eval("@#{f.to_s}") }
            h
        end

        #
        # Rebuilds a FlowExpressionId from its Hash representation.
        #
        def FlowExpressionId.from_h (h)

            fei = FlowExpressionId.new
            FIELDS.each { |f| fei.instance_variable_set("@#{f}", h[f]) }
            fei
        end

        def hash ()
            to_s().hash()
        end

        def == (other)

            return false if not other.kind_of?(FlowExpressionId)

            #return self.to_s == other.to_s
                # no perf gain

            @workflow_instance_id == other.workflow_instance_id and
            @expression_id == other.expression_id and
            @workflow_definition_url == other.workflow_definition_url and
            @workflow_definition_revision == other.workflow_definition_revision and
            @workflow_definition_name == other.workflow_definition_name and
            @expression_name == other.expression_name and
            @owfe_version == other.owfe_version and 
            @engine_id == other.engine_id and 
            @initial_engine_id == other.initial_engine_id
                #
                # Make sure to put on top of the 'and' the things that
                # change the most...
        end

        #
        # Returns true if this other FlowExpressionId is nested within
        # this one.
        #
        # For example (fei TestTag 3 20070331-goyunodabu 0.0.0 sequence)
        # is an ancestor of (fei TestTag 3 20070331-goyunodabu 0.0.0.1 redo)
        #
        # This current implementation doesn't cross the subprocesses 
        # boundaries.
        #
        def ancestor_of? (other_fei)

            o = other_fei.dup
            o.expression_name = @expression_name
            o.expression_id = @expression_id

            return false unless self == o

            OpenWFE::starts_with other_fei.expression_id, @expression_id
        end

        #
        # Returns a deep copy of this FlowExpressionId instance.
        #
        def dup

            OpenWFE::fulldup(self)
        end

        alias eql? ==

        def to_debug_s
            "(fei #{@workflow_definition_name} #{@workflow_definition_revision} #{@workflow_instance_id} #{@expression_id} #{@expression_name})"
        end

        #
        # Returns a very short string representation (fei wfid expid expname).
        #
        def to_short_s
            "(fei #{@workflow_instance_id} #{@expression_id} #{@expression_name})"
        end

        #
        # Returns a URI escaped string with just the wfid and the expid, like
        # '20070917-dupibodasa__0.0.1'
        #
        # Useful for unique identifier in URIs.
        #
        def to_web_s

            eid = expid.gsub("\.", "_")
            URI.escape("#{workflow_instance_id}__#{eid}")
        end

        #
        # Yet another debugging method. Just returns the sub_instance_id and
        # the expression_id, in a string.
        #
        def to_env_s
            "i#{sub_instance_id}  #{@expression_id}"
        end

        #
        # Returns the workflow instance id without any subflow indices.
        # For example, if the wfid is "1234.0.1", this method will
        # return "1234".
        #
        def parent_workflow_instance_id
            i = workflow_instance_id.index(".")
            return workflow_instance_id unless i
            workflow_instance_id[0..i-1]
        end

        alias :parent_wfid :parent_workflow_instance_id

        #
        # Returns "" if this expression id belongs to a top process,
        # returns something like ".0" or ".1.3" if this exp id belongs to
        # an expression in a subprocess.
        # (Only used in some unit tests for now)
        #
        def sub_instance_id
            i = workflow_instance_id.index(".")
            return "" unless i
            workflow_instance_id[i..-1]
        end

        #
        # Returns the last part of the expression_id. For example, if
        # the expression_id is "0.1.0.4", "4" will be returned.
        #
        # This method is used in "concurrence" when merging workitems coming
        # backing from the children expressions.
        #
        def child_id
            i = @expression_id.rindex(".")
            return @expression_id unless i
            @expression_id[i+1..-1]
        end

        #
        # This class method parses a string into a FlowExpressionId instance
        #
        def FlowExpressionId.to_fei (string)

            fei = FlowExpressionId.new()

            ss = string.split(" ")

            #require 'pp'; puts; pp ss

            ss = ss[1..-1] if ss[0] == "("

            fei.owfe_version = ss[1]

            ssRawEngineId = ss[2].split("/")
            fei.engine_id= ssRawEngineId[0]
            fei.initial_engine_id= ssRawEngineId[1]

            fei.workflow_definition_url = ss[3]
            fei.workflow_definition_name = ss[4]
            fei.workflow_definition_revision = ss[5]
            fei.workflow_instance_id = ss[6]
            fei.expression_name = ss[7]
            fei.expression_id = ss[8][0..-2]

            fei.expression_id = fei.expression_id[0..-2] \
                if fei.expression_id[-1, 1] == ")"

            fei
        end

        #
        # An alias for to_fei(string)
        #
        def FlowExpressionId.from_s (string)
            FlowExpressionId.to_fei(string)
        end
    end

end

