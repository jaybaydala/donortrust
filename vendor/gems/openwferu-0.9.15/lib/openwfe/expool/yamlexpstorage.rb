#
#--
# Copyright (c) 2006-2007, Nicolas Modryzk and John Mettraux, OpenWFE.org
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
# Nicolas Modrzyk at openwfe.org
# John Mettraux at openwfe.org
#

require 'openwfe/utils'
require 'openwfe/storage/yamlcustom'
require 'openwfe/storage/yamlfilestorage'

require 'openwfe/expressions/flowexpression'
require 'openwfe/expressions/raw_xml'
    #
    # making sure classes in those files are loaded
    # before their yaml persistence is tuned
    # (else the reopening of the class is interpreted as
    # a definition of the class...)


module OpenWFE
    
    #
    # YAML expression storage. Expressions (atomic pieces of process instances)
    # are stored in a hierarchy of YAML files.
    #
    class YamlFileExpressionStorage  < YamlFileStorage
        include OwfeServiceLocator
        include ExpressionStorageBase
        
        def initialize (service_name, application_context)

            super(service_name, application_context, '/expool')

            observe_expool
        end

        #
        # Iterates on each expression that is of the given kind.
        # Used for example by the expression pool when rescheduling.
        #
        def each_of_kind (kind, &block)

            return unless block

            each_object_path do |path|

                #ldebug { "each_of_kind() path is #{path}" }

                #next unless matches(path, kind)
                    # was not OK in case of <bob activity="clean office" />

                expression = load_object(path)

                next unless expression.is_a?(kind)

                expression.application_context = @application_context

                block.call expression
            end
        end

        #
        # "each flow expression" : this method awaits a block then, for
        # each flow_expression in this storage, calls that block.
        #
        # If wfid_prefix is set, only expressions whose wfid (workflow instance
        # id (process instance id)) will be taken into account.
        #
        def each (wfid_prefix=nil, &block)

            each_object_path do |path|

                a = self.class.split_file_path path
                next unless a
                wfid = a[0]
                next if wfid_prefix and ( ! wfid.match "^#{wfid_prefix}")
                flow_expression = load_object path

                block.call flow_expression.fei, flow_expression
            end
        end

        alias :real_each :each

        #
        # Returns a human-readable list of the current YAML file paths.
        # (one expression per path).
        #
        def to_s

            s = "\n\n==== #{self.class} ===="
            s << "\n"
            each_object_path do |path|
                s << path
                s << "\n"
            end
            s << "==== . ====\n"
            s
        end

        #
        # Returns nil (if the path doesn't match an stored expression path)
        # or an array [ workflow_instance_id, expression_id, expression_name ].
        #
        # This is a class method (not an instance one).
        #
        def self.split_file_path (path)

            md = path.match %r{.*/(.*)__([\d.]*)_(.*).yaml}
            return nil unless md
            [ md[1], md[2], md[3] ]
        end

        protected

            def compute_file_path (fei)
                
                return @basepath + "/engine_environment.yaml" \
                    if fei.workflow_instance_id == "0"
                    
                wfid = fei.parent_workflow_instance_id

                a_wfid = get_wfid_generator.split_wfid(wfid)
                
                @basepath +
                a_wfid[-2] + "/" +
                a_wfid[-1] + "/" +
                fei.workflow_instance_id + "__" +
                fei.expression_id + "_" + 
                fei.expression_name + ".yaml"
            end        

            #--
            # Returns true if the path points to a file containing an 
            # expression whose name is in the list of expression names
            # corresponding to the given kind (class) of expressions.
            #
            #def matches (path, kind)
            #    exp_names = get_expression_map.get_expression_names(kind)
            #    exp_names.each do |exp_name|
            #        return true \
            #            if OpenWFE::ends_with(path, "_#{exp_name}.yaml")
            #    end
            #    false
            #end
            #++
    end

    #
    # This mixin gathers all the logic for a threaded expression storage,
    # one that doesn't immediately stores workitems (removes overriding
    # operations).
    # Using this threaded storage brings a very important perf benefit.
    #
    module ThreadedStorageMixin

        THREADED_FREQ = "427" # milliseconds
            #
            # the frequency at which the event queue should be processed

        #
        # Will take care of stopping the 'queue processing' thread.
        #
        def stop

            get_scheduler.unschedule(@thread_id) if @thread_id

            process_queue()
                #
                # flush every remaining events (especially the :delete ones)
        end

        #
        # calls process_queue() before the call the super class each_of_kind()
        # method
        #
        def each_of_kind (kind, &block)

            #ldebug { "each_of_kind()" }

            process_queue()
            super
        end

        #
        # calls process_queue() before the call the super class each()
        # method
        #
        def each (wfid_prefix=nil, &block)

            process_queue()
            super
        end

        protected

            #
            # starts the thread that does the actual persistence.
            #
            def start_processing_thread

                @events = {}
                @op_count = 0

                @thread_id = get_scheduler.schedule_every THREADED_FREQ do
                    process_queue
                end
            end

            #
            # queues an event for later (well within a second) persistence
            #
            def queue (event, fei, fe=nil)
                synchronize do

                    old_size = @events.size
                    @op_count += 1

                    @events[fei] = [ event, fei, fe ]

                    ldebug do 
                        "queue() ops #{@op_count} "+
                        "size #{old_size} -> #{@events.size}"
                    end
                end
            end

            #
            # the actual "do persist" order
            #
            def process_queue

                return unless @events.size > 0
                    #
                    # trying to exit as quickly as possible

                ldebug do 
                    "process_queue() #{@events.size} events #{@op_count} ops"
                end

                synchronize do
                    @events.each_value do |v|
                        event = v[0]
                        begin
                            if event == :update
                                self[v[1]] = v[2]
                            else
                                safe_delete(v[1])
                            end
                        rescue Exception => e
                            lwarn do
                                "process_queue() ':#{event}' exception\n" + 
                                OpenWFE::exception_to_s(e)
                            end
                        end
                    end
                    @op_count = 0
                    @events.clear
                end
            end

            #
            # a call to delete that tolerates missing .yaml files
            #
            def safe_delete (fei)
                begin
                    self.delete(fei)
                rescue Exception => e
                #    lwarn do
                #        "safe_delete() exception\n" + 
                #        OpenWFE::exception_to_s(e)
                #    end
                end
            end

            #
            # Adds the queue() method as an observer to the update and remove
            # events of the expression pool.
            # :update and :remove mean changes to expressions in the persistence
            # that's why they are observed.
            #
            def observe_expool

                get_expression_pool.add_observer(:update) do |event, fei, fe|
                    ldebug { ":update  for #{fei.to_debug_s}" }
                    queue(event, fei, fe)
                end
                get_expression_pool.add_observer(:remove) do |event, fei|
                    ldebug { ":remove  for #{fei.to_debug_s}" }
                    queue(event, fei)
                end
            end
    end

    #
    # With this extension of YmalFileExpressionStorage, persistence occurs
    # in a separate thread, for a snappier response.
    #
    class ThreadedYamlFileExpressionStorage < YamlFileExpressionStorage
        include ThreadedStorageMixin

        def initialize (service_name, application_context)

            super

            start_processing_thread()
                #
                # which sets @thread_id
        end
    end
end
