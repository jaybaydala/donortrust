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

#require 'monitor'
require 'fileutils'

require 'openwfe/service'
require 'openwfe/util/lru'
require 'openwfe/flowexpressionid'

module OpenWFE

    #
    # This module contains the observe_expool method which binds the
    # storage to the expression pool.
    # It also features a to_s method for the expression storages including
    # it.
    #
    module ExpressionStorageBase

        def observe_expool

            get_expression_pool.add_observer(:update) do |channel, fei, fe|
                ldebug { ":update  for #{fei}" }
                self[fei] = fe
            end
            get_expression_pool.add_observer(:remove) do |channel, fei|
                ldebug { ":delete  for #{fei}" }
                self.delete(fei)
            end
        end

        def to_s

            s = "\n\n==== #{self.class} ===="

            self.each do |k, v|
                s << "\n"
                if v.kind_of?(RawExpression)
                    s << "*raw" 
                else
                    s << "  "
                end
                #s << v.to_s
                s << v.fei.to_s
                s << "    key/value mismatch !" if k != v.fei
            end
            s << "\n==== . ====\n"

            s
        end
    end

    #
    # This cache uses a LruHash (Least Recently Used) to store expressions.
    # If an expression is not cached, the 'real storage' is consulted.
    # The real storage is supposed to be the service named
    # "expressionStorage.1"
    #
    class CacheExpressionStorage
        include ServiceMixin
        include OwfeServiceLocator
        include ExpressionStorageBase

        #
        # under 20 stored expressions, the unit tests for the 
        # CachedFilePersistedEngine do fail because the persistent storage
        # behind the cache hasn't the time to flush its work queue.
        # a min size limit has been set to 77.
        #
        MIN_SIZE = 77

        DEFAULT_SIZE = 5000

        def initialize (service_name, application_context)

            super()

            service_init(service_name, application_context)

            size = @application_context[:expression_cache_size]
            size = DEFAULT_SIZE unless size
            size = MIN_SIZE unless size > MIN_SIZE

            linfo { "new() size is #{size}" }

            @cache = LruHash.new(size)

            @real_storage = nil

            observe_expool
        end

        def [] (fei)

            #ldebug { "[] size is #{@cache.size}" }
            #ldebug { "[] (sz #{@cache.size}) for #{fei.to_debug_s}" }

            fe = @cache[fei.hash]
            return fe if fe

            ldebug { "[] (reload) for #{fei.to_debug_s}" }

            fe = get_real_storage[fei]

            unless fe
                #ldebug { "[] (reload) miss for #{fei.to_debug_s}" }
                return nil 
            end

            @cache[fei.hash] = fe

            fe
        end

        def []= (fei, fe)
            @cache[fei.hash] = fe
        end

        def delete (fei)
            @cache.delete fei.hash
        end

        def length
            @cache.length
        end

        alias :size :length

        def clear
            @cache.clear
        end

        alias :purge :clear

        #
        # Simply redirects the call to the each_of_kind() method of 
        # the 'real storage'.
        #
        def each_of_kind (kind, &block)

            get_real_storage.each_of_kind(kind, &block)
        end

        #
        # Passes a block to the expressions currently in the cache.
        #
        def each (wfid_prefix=nil, &block)

            #@cache.each(&block)

            if wfid_prefix
                @cache.each do |fei, fexp|
                    next unless fei.wfid.match "^#{wfid_prefix}"
                    block.call fei, fexp
                end
            else
                @cache.each(&block)
            end
        end

        #
        # This each() just delegates to the real storage each() method.
        #
        def real_each (wfid_prefix=nil, &block)

            get_real_storage.each(wfid_prefix, &block)
        end

        protected

            #
            # Returns the "real storage" i.e. the storage that does the real
            # persistence behind this "cache storage".
            #
            def get_real_storage

                return @real_storage if @real_storage

                @real_storage = 
                    @application_context[S_EXPRESSION_STORAGE + ".1"]

                @real_storage
            end
    end
        
    #
    # Memory consuming in-memory storage.
    # No memory limit, puts everything in a Hash
    #
    class InMemoryExpressionStorage < Hash
        include ServiceMixin
        include OwfeServiceLocator
        include ExpressionStorageBase
        
        def initialize (service_name, application_context)

            service_init(service_name, application_context)

            observe_expool
        end

        alias :purge :clear

        #
        # Allows to pass a block to each expressions of a given kind (type).
        #
        def each_of_kind (kind, &block)

            return unless block

            self.each_value do |fexp|
                block.call(fexp) if fexp.kind_of?(kind)
            end
        end

        def each (wfid_prefix=nil, &block)

            if wfid_prefix

                super() do |fei, fexp|
                    next unless fei.wfid.match "^#{wfid_prefix}"
                    block.call fei, fexp
                end
            else

                super(&block)
            end
        end

        alias :real_each :each

    end

end
