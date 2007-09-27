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

require 'yaml'

require 'openwfe/utils'
require 'openwfe/participants/participant'


#
# some base participant implementations
#
module OpenWFE

    #
    # Just dumps the incoming workitem in a file as a YAML String.
    #
    # By default, this participant will not reply to the engine once
    # the workitem got dumped to its file, but you can set its 
    # reply_anyway field to true to make it reply anyway...
    #
    class FileParticipant
        include LocalParticipant

        attr_accessor :reply_anyway, :workdir

        #
        # The constructor expects as a unique optional param either the 
        # application_context either the 'output' dir for the participant.
        #
        def initialize (context_or_dir=nil)

            @workdir = get_work_directory(context_or_dir) + "/out/"

            @reply_anyway = false
        end

        #
        # The method called by the engine for each incoming workitem.
        #
        def consume (workitem)

            FileUtils.makedirs(@workdir) unless File.exist?(@workdir)

            file_name = @workdir + determine_file_name(workitem)

            dump_to_file(file_name, workitem)

            reply_to_engine(workitem) if @reply_anyway
        end

        #
        # This method does the actual job of dumping the workitem (as some
        # YAML to a file).
        # It can be easily overriden.
        #
        def dump_to_file (file_name, workitem)

            File.open(file_name, "w") do |file|
                file.print encode_workitem(workitem)
            end
        end

        #
        # You can override this method to control into which file (name)
        # each workitem gets dumped.
        # You could even have a unique file for all workitems transiting
        # through this participant.
        #
        def determine_file_name (workitem)

            fei = workitem.fei

            OpenWFE::ensure_for_filename(
                "#{fei.wfid}_#{fei.expression_id}__" +
                "#{fei.workflow_definition_name}__" +
                "#{fei.workflow_definition_revision}" +
                "#{workitem.participant_name}.yaml")
        end

        protected

            #
            # By default, uses YAML to serialize the workitem
            # (of course you can override this method).
            #
            def encode_workitem (wi)
                YAML.dump(wi)
            end
    end
        
    #
    # This participant is used by the register_participant() method of
    # Engine class.
    #
    #     engine.register_participant("the_boss") do |workitem|
    #         puts "the boss received a workitem"
    #     end
    #
    # After the block executes, the BlockParticipant immediately replies
    # to the engine.
    #
    # You can pass a block with two arguments : flow_expression and workitem
    # to BlockParticipant, it will automatically adapt.
    #
    #     engine.register_participant("the_boss") do |fexp, wi|
    #         puts "the boss received a workitem from exp #{fexp.fei.to_s}"
    #     end
    #
    # Having the FlowExpression instance at hand allows for advanced tricks,
    # beware...
    #
    # It's also OK to register a block participant without params :
    #
    #     engine.register_participant :alice do
    #         puts "Alice received a workitem"
    #     end
    #
    class BlockParticipant 
        include LocalParticipant

        def initialize (block0=nil, &block1)
            @block = if block1
                block1
            else
                block0
            end
            raise "Missing a block parameter" \
                unless @block
        end

        def consume (workitem)

            result = call_block @block, workitem

            workitem.set_result(result) if result

            reply_to_engine(workitem) \
                if workitem.kind_of? InFlowWorkItem
            # else it's a cancel item
        end
    end

    #
    # Simply aliasing a participant.
    #
    #     engine.register_participant "toto" do |workitem|
    #         workitem.toto_message = "toto was here"
    #     end
    #     engine.register_participant "user_.*", AliasParticipant.new("toto")
    #
    # Workitems for participant whose name starts with 'user_' will be handled
    # by participant 'toto'.
    # Note that you can't use use a regex as the aliased name ("toto" in the 
    # example).
    #
    class AliasParticipant
        include LocalParticipant

        attr_reader :aliased_name

        def initialize (aliased_name)

            @aliased_name = aliased_name
        end

        def consume (workitem)

            get_participant_map.dispatch(nil, @aliased_name, workitem)
        end
    end

    #
    # The NullParticipant never replies, it simply discards the workitems
    # it receives.
    #
    class NullParticipant
        include LocalParticipant

        #
        # Simply discards the incoming workitem
        #
        def consume (workitem)
            # does nothing and does not reply to the engine.
        end
    end

    #
    # The NoOperationParticipant immediately replies to the engine upon 
    # receiving a workitem.
    #
    class NoOperationParticipant
        include LocalParticipant

        #
        # Simply discards the incoming workitem
        #
        def consume (workitem)
            reply_to_engine workitem
        end
    end

    #
    # The PrintParticipant will just emit its name to the
    # test tracer if any or to the stdout else.
    # Used by some unit tests.
    #
    class PrintParticipant 
        include LocalParticipant

        def consume (workitem)

            tracer = @application_context['__tracer']

            if tracer
                tracer << workitem.participant_name
                tracer << "\n"
            else
                puts workitem.participant_name
            end

            reply_to_engine(workitem)
        end
    end

    #
    # Links a process under a participant [name].
    #
    # Turns top level processes into participants
    #
    # Some examples :
    #
    #     require 'engine/participants/participants'
    #
    #     engine.register_participant(
    #         "transmit_to_accounting", 
    #         "http://company.process.server.ie/processes/acc0.xml")
    #
    #     engine.register_participant(
    #         "hr_resume_review_process",
    #         "file:/var/processes/hr_resume_review_process.rb")
    #
    # Some more examples :
    #
    #     class RegistrationProcess < OpenWFE::ProcessDefinition
    #         sequence do
    #             participant :ref => "Alice"
    #             participant :ref => "Bob"
    #         end
    #     end
    #
    #     # later in the code ...
    #    
    #     engine.register_participant("registration", RegistrationProcess)
    #
    # Or directly with some XML string :
    #
    #     engine.register_participant("registration", '''
    #         <process-definition name="registration" revision="0.1">
    #             <sequence>
    #                 <participant ref="Alice" />
    #                 <participant ref="Bob" />
    #             </sequence>
    #         </process-definition>
    #     '''.strip)
    #
    # It's then easy to call the subprocess as if it were a participant :
    #
    #     sequence do
    #         participant :ref => "registration"
    #             # or
    #         participant  "registration"
    #             # or simply
    #         registration
    #     end
    #
    # Note that the 'subprocess' expression may be used as well :
    #
    #     sequence do
    #         subprocess ref => "http://dms.company.org/processes/proc1.rb"
    #     end
    #
    # But you can't use the URL as an expression name for writing nice,
    # concise, process definitions.
    #
    class ProcessParticipant
        include LocalParticipant

        #
        # The 'object' may be the URL of a process definition or the process
        # definition itself as an XML string or a Ruby process definition
        # (as a class or in a String).
        #
        def initialize (object)

            super()

            template_uri = OpenWFE::parse_known_uri object

            @template = template_uri || object
        end

        #
        # This is the method called by the engine when it has a workitem
        # for this participant.
        #
        def consume (workitem)

            get_expression_pool.launch_template(
                get_flow_expression(workitem),
                0, #sub_id
                @template, 
                workitem) 
                #params)
        end
    end

end

