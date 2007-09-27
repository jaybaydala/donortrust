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
require 'openwfe/rudefinitions'
require 'openwfe/expressions/merge'
require 'openwfe/expressions/condition'
require 'openwfe/expressions/flowexpression'
require 'openwfe/expressions/fe_iterator'


#
# base expressions like 'sequence' and 'concurrence'
#

module OpenWFE

    #
    # The concurrence expression will execute each of its (direct) children
    # in parallel threads.
    #
    # Thus,
    #
    #     <concurrence>
    #         <participant ref="pa" />
    #         <participant ref="pb" />
    #     </concurrence>
    #
    # Participants pa and pb will be 'treated' in parallel (quasi 
    # simultaneously).
    #
    # The concurrence expressions accept many attributes, that can get
    # combined. By default, the concurrence waits for all its children to 
    # reply and returns the workitem of the first child that replied.
    # The attributes tune this behaviour.
    #
    # <em>count</em>
    #
    #     <concurrence count="1">
    #         <participant ref="pa" />
    #         <participant ref="pb" />
    #     </concurrence>
    #
    # The concurrence will be over as soon as 'pa' or 'pb' replied, i.e.
    # as soon as "1" child replied.
    #
    # <em>remaining</em>
    #
    # The attribute 'remaining' can take two values 'cancel' (the default) and
    # 'forget'.
    # Cancelled children are completely wiped away, forgotten ones continue
    # to operate but their reply will simply get discarded.
    #
    # <em>over-if</em>
    #
    # 'over-if' accepts a 'boolean expression' (something replying 'true' or
    # 'false'), if the expression evaluates to true, the concurrence will be
    # over and the remaining children will get cancelled (the default) or 
    # forgotten.
    #
    # <em>merge</em>
    #
    # By default, the first child to reply to its parent 'concurrence' 
    # expression 'wins', i.e. its workitem is used for resuming the flow (after
    # the concurrence).
    #
    # [first]    The default : the first child to reply wins
    # [last]     The last child to reply wins
    # [highest]  The first 'defined' child (in the list of children) will win
    # [lowest]   The last 'defined' child (in the list of children) will win
    #
    # Thus, in that example
    #
    #     <concurrence merge="lowest">
    #         <participant ref="pa" />
    #         <participant ref="pb" />
    #     </concurrence>
    #
    # when the concurrence is done, the workitem of 'pb' is used to resume the
    # flow after the concurrence.
    #
    # <em>merge-type</em>
    #
    # [override]  The default : no mix of values between the workitems do occur
    # [mix]       Priority is given to the 'winning' workitem but their values
    #             get mixed
    # [isolate]   the attributes of the workitem of each branch is placed 
    #             in a field in the resulting workitem. For example, the 
    #             attributes of the first branch will be stored under the
    #             field named '0' of the resulting workitem.
    #
    # The merge occurs are the top level of workitem attributes.
    #
    # More complex merge behaviour can be obtained by extending the 
    # GenericSyncExpression class. But the default sync options are already
    # numerous and powerful by their combinations.
    #
    class ConcurrenceExpression < SequenceExpression
        include ConditionMixin

        names :concurrence

        attr_accessor \
            :sync_expression

        def apply (workitem)

            sync = lookup_attribute(:sync, workitem, :generic)

            @sync_expression = 
                get_expression_map.get_sync_class(sync).new(self, workitem)

            @children.each do |child|
                @sync_expression.add_child(child)
            end

            store_itself()

            concurrence = self

            @children.each_with_index do |child, index|
                Thread.new do
                    begin
                        #ldebug { "apply() child : #{child.to_debug_s}" }
                        concurrence.synchronize do

                            get_expression_pool().apply(
                                child, 
                                #workitem.dup)
                                get_workitem(workitem, index))
                        end
                    rescue Exception => e
                        lwarn do 
                            "apply() " +
                            "caught exception in concurrent child  " + 
                            child.to_debug_s + "\n" + 
                            OpenWFE::exception_to_s(e)
                        end
                    end
                end
            end

            #@sync_expression.ready(self)
                #
                # this is insufficient, have to do that :

            synchronize do
                #
                # Making sure the freshest version of the concurrence
                # expression is used.
                # This is especially important when using pure persistence.
                #
                reloaded_self, _fei = get_expression_pool.fetch(@fei)
                reloaded_self.sync_expression.ready(reloaded_self)
            end
        end

        def reply (workitem)
            @sync_expression.reply(self, workitem)
        end

        protected

            def get_workitem (workitem, index)
                workitem.dup
            end
    end

    #
    # This expression is a mix between a 'concurrence' and an 'iterator'.
    # It understands the same attributes and behaves as an interator that
    # forks its children concurrently.
    #
    # (See ConcurrenceExpression and IteratorExpression).
    #
    class ConcurrentIteratorExpression < ConcurrenceExpression

        names :concurrent_iterator

        attr_accessor :template

        def apply (workitem)

            if @children.length < 1
                reply_to_parent workitem
                return
            end

            @template = @children[0]

            @children.clear

            @workitems = []

            iterator = Iterator.new(self, workitem)

            unless iterator.has_next?
                reply_to_parent workitem
                return
            end

            while iterator.has_next?

                wi = workitem.dup

                @workitems << wi

                vars = iterator.next wi

                rawexp = get_expression_pool.prepare_from_template(
                    self, iterator.index, template, vars)

                @children << rawexp.fei
            end

            super
        end

        def reply_to_parent (workitem)

            get_expression_pool.remove(@template)
            super
        end

        protected

            def get_workitem (workitem, index)

                @workitems[index]
            end
    end

    #
    # A base for sync expressions, currently empty.
    # That may change.
    #
    class SyncExpression < ObjectWithMeta

        def initialize()

            super
        end

        def self.names (*exp_names)

            exp_names = exp_names.collect do |n|
                n.to_s
            end
            meta_def :expression_names do
                exp_names
            end
        end
    end

    #
    # The classical OpenWFE sync expression.
    # Used by 'concurrence' and 'concurrent-iterator'
    #
    class GenericSyncExpression < SyncExpression

        names :generic

        attr_accessor \
            :remaining_children,
            :count,
            :reply_count,
            :cancel_remaining,
            :unready_queue

        def initialize (synchable, workitem)

            super()

            @remaining_children = []
            @reply_count = 0

            @count = determine_count(synchable, workitem)
            @cancel_remaining = cancel_remaining?(synchable, workitem)

            merge = synchable.lookup_attribute(:merge, workitem, :first)
            merge_type = synchable.lookup_attribute(:merge_type, workitem, :mix)

            #synchable.ldebug { "new() merge_type is '#{merge_type}'" }

            @merge_array = MergeArray.new(merge, merge_type)

            @unready_queue = []
        end

        #
        # when all the children got applied concurrently, the concurrence
        # calls this method to notify the sync expression that replies
        # can be processed
        #
        def ready (synchable)
            synchable.synchronize do

                synchable.ldebug do 
                    "ready() called by  #{synchable.fei.to_debug_s}  " +
                    "#{@unready_queue.length} wi waiting"
                end

                queue = @unready_queue
                @unready_queue = nil
                synchable.store_itself()

                queue.each do |workitem|
                    break if do_reply(synchable, workitem)
                        #
                        # do_reply() will return 'true' as soon as the 
                        # concurrence is over, if this is the case, the
                        # queue should not be treated anymore
                end
            end
        end

        def add_child (child)
            @remaining_children << child
        end

        def reply (synchable, workitem)
            synchable.synchronize do

                if @unready_queue

                    @unready_queue << workitem

                    synchable.store_itself()

                    synchable.ldebug do 
                        "#{self.class}.reply() "+
                        "#{@unready_queue.length} wi waiting..."
                    end

                else
                    do_reply(synchable, workitem)
                end
            end
        end

        protected

            def do_reply (synchable, workitem)

                synchable.ldebug do 
                    "#{self.class}.do_reply() from " +
                    "#{workitem.last_expression_id.to_debug_s}"
                end

                @merge_array.push(synchable, workitem)

                @reply_count = @reply_count + 1

                @remaining_children.delete(workitem.last_expression_id)

                #synchable.ldebug do
                #    "#{self.class}.do_reply()  "+
                #    "remaining children : #{@remaining_children.length}"
                #end

                if @remaining_children.length <= 0
                    reply_to_parent(synchable)
                    return true
                end

                if @count > 0 and @reply_count >= @count
                    treat_remaining_children(synchable)
                    reply_to_parent(synchable)
                    return true
                end

                #
                # over-if

                conditional = 
                    synchable.eval_condition("over-if", workitem, "over-unless")

                if conditional
                    treat_remaining_children(synchable)
                    reply_to_parent(synchable)
                    return true
                end

                #
                # not over, resuming

                synchable.store_itself()

                #synchable.ldebug do
                #    "#{self.class}.do_reply() not replying to parent "+
                #    "#{workitem.last_expression_id.to_debug_s}"
                #end

                false
            end

            def reply_to_parent (synchable)

                workitem = @merge_array.do_merge

                synchable.reply_to_parent(workitem)
            end

            def treat_remaining_children (synchable)

                expool = synchable.get_expression_pool

                @remaining_children.each do |child|

                    synchable.ldebug do 
                        "#{self.class}.treat_remainining_children() " +
                        "#{child.to_debug_s} " +
                        "(cancel ? #{@cancel_remaining})"
                    end

                    if @cancel_remaining
                        expool.cancel(child)
                    else
                        expool.forget(synchable, child)
                    end
                end
            end

            def cancel_remaining? (synchable_expression, workitem)

                s = synchable_expression.lookup_attribute(
                    :remaining, workitem, :cancel)

                return s == :cancel.to_s
            end

            def determine_count (synchable_expression, workitem)

                s = synchable_expression.lookup_attribute(:count, workitem)
                return -1 if not s
                i = s.to_i
                return -1 if i < 1
                i
            end

            #
            # This inner class is used to gather workitems (via push()) before 
            # the final merge
            # This final merge is triggered by calling the do_merge() method
            # which will return the resulting, merged workitem.
            #
            class MergeArray
                include MergeMixin

                attr_accessor \
                    :workitem,
                    :workitems_by_arrival,
                    :workitems_by_altitude,
                    :merge,
                    :merge_type

                def initialize (merge, merge_type)

                    @merge = merge.strip.downcase.intern
                    @merge_type = merge_type.strip.downcase.intern

                    ensure_merge_settings()

                    @workitem = nil

                    if highest? or lowest?
                        @workitems_by_arrival = []
                        @workitems_by_altitude = []
                    end
                end

                def push (synchable, wi)

                    #synchable.ldebug do
                    #    "push() isolate? #{isolate?}"
                    #end

                    if isolate?
                        push_in_isolation wi
                    elsif last? or first?
                        push_by_position wi
                    else
                        push_by_arrival wi
                    end
                end

                def push_by_position (wi)

                    source, target = if first?
                        [ @workitem, wi ]
                    else
                        [ wi, @workitem ]
                    end
                    @workitem = merge_workitems target, source, override?
                end

                def push_in_isolation (wi)

                    unless @workitem
                        @workitem = wi.dup
                        att = @workitem.attributes
                        @workitem.attributes = {}
                    end

                    #key = synchable.children.index wi.last_expression_id
                    key = wi.last_expression_id.child_id

                    @workitem.attributes[key.to_s] = 
                        OpenWFE::fulldup(wi.attributes)
                end

                def push_by_arrival (wi)

                    #index = synchable.children.index wi.last_expression_id
                    index = Integer(wi.last_expression_id.child_id)

                    @workitems_by_arrival << wi
                    @workitems_by_altitude[index] = wi
                end

                #
                # merges the workitems stored here
                #
                def do_merge

                    return @workitem if @workitem

                    list = if first?
                        @workitems_by_arrival.reverse
                    elsif last?
                        @workitems_by_arrival
                    elsif highest?
                        @workitems_by_altitude.reverse
                    elsif lowest?
                        @workitems_by_altitude
                    end

                    result = nil

                    list.each do |wi|
                        next unless wi
                        result = merge_workitems result, wi, override?
                    end

                    #puts "___ result :"
                    #puts result.to_s
                    #puts

                    result
                end

                protected

                    def first?
                        @merge == :first
                    end
                    def last?
                        @merge == :last
                    end
                    def highest?
                        @merge == :highest
                    end
                    def lowest?
                        @merge == :lowest
                    end

                    def mix?
                        @merge_type == :mix
                    end
                    def override?
                        @merge_type == :override
                    end
                    def isolate?
                        @merge_type == :isolate
                    end

                    #
                    # Making sure @merge and @merge_type are set to
                    # appropriate values.
                    #
                    def ensure_merge_settings

                        @merge_type = :mix unless override? or isolate?
                        @merge = :first unless last? or highest? or lowest?
                    end
            end

    end

end

