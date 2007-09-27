
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Sun Oct 29 16:18:25 JST 2006
#

require 'test/unit'
require 'openwfe/util/lru'

include OpenWFE


#
# testing the lru hash things
#

class LruTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    def test_lru_0

        h = LruHash.new(3)

        assert h.size == 0

        h[:a] = "A"

        assert h.size == 1

        h[:b] = "B"
        h[:c] = "C"

        assert h.size == 3
        assert h.ordered_keys == [ :a, :b, :c ]

        h[:d] = "D"

        assert h.size == 3
        assert h.ordered_keys == [ :b, :c, :d ]
        assert h[:a] == nil
        assert h[:b] == "B"
        assert h.ordered_keys == [ :c, :d, :b ]

        h.delete(:d)

        #require 'pp'
        #puts "lru keys :"
        #pp h.ordered_keys

        assert h.size == 2
        assert h.ordered_keys == [ :c, :b ]

        h[:a] = "A"

        assert h.size == 3
        assert h.ordered_keys == [ :c, :b, :a ]

        h[:d] = "D"


        assert h.size == 3
        assert h.ordered_keys == [ :b, :a, :d ]

        assert h[:b] == "B"
        assert h[:a] == "A"
        assert h[:d] == "D"
        assert h[:c] == nil
        assert h.ordered_keys == [ :b, :a, :d ]
    end

end
