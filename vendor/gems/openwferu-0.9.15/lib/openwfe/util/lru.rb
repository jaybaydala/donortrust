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

#require 'monitor'


module OpenWFE

    #
    # A Hash that has a max size. After the maxsize has been reached, the
    # least recently used entries (LRU hence), will be discared to make
    # room for the new entries.
    #
    class LruHash
        #include MonitorMixin
            #
            # seems not necessary for now, and it collides with expool's
            # @monitors own sync

        def initialize (maxsize)

            super()

            @maxsize = maxsize

            @hash = {}
            @lru_keys = []
        end

        def maxsize= (newsize)
            remove_lru() while @hash.size > newsize
            @maxsize = newsize
        end

        def maxsize
            return @maxsize
        end

        def size
            return @lru_keys.size
        end
        alias :length :size

        def keys
            return @hash.keys
        end
        def values
            return @values
        end

        def clear
            @hash.clear
            @lru_keys.clear
        end

        def each (&block)
            return unless block
            @hash.each do |k, v|
                block.call(k, v)
            end
        end

        #
        # Returns the keys with the lru in front.
        #
        def ordered_keys
            return @lru_keys
        end

        def [] (key)
            value = @hash[key]
            return nil unless value
            touch(key)
            return value
        end

        def []= (key, value)
            remove_lru() while @hash.size >= @maxsize
            @hash[key] = value
            touch(key)
            return value
        end

        def delete (key)
            value = @hash.delete(key)
            @lru_keys.delete(key)
            return value
        end

        def include? (key)
            return @hash.include?(key)
        end

        protected

            #
            # Puts the key on top of the lru 'stack'.
            # The bottom being the lru place.
            #
            def touch (key)
                @lru_keys.delete(key)
                @lru_keys << key
            end

            #
            # Removes the lru value and returns it.
            # Returns nil if the cache is currently empty.
            #
            def remove_lru ()
                return nil if @lru_keys.size < 1
                key = @lru_keys.delete_at(0)
                return @hash.delete(key)
            end
    end
end

