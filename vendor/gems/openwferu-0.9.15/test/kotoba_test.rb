
#
# Testing OpenWFE (Kotoba)
#
# John Mettraux at openwfe.org
#
# Sun Mar 18 13:29:37 JST 2007
#

require 'test/unit'
require 'openwfe/util/kotoba'

#
# testing misc things
#

class KotobaTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    def test_kotoba
        t = Time.now
        #puts t.to_f
        
        st = t.to_f * 1000 * 10
        
        #puts st
        
        st = Integer(st) % (10 * 1000 * 60 * 60)
        #st = 28340469
        
        s = Kotoba::from_integer(st)
        
        st2 = Kotoba::to_integer(s)
        s2 = Kotoba::from_integer(st2)
        
        #puts st
        #puts s
        
        #puts st2
        #puts s2

        assert_equal s, s2
        assert_equal st, st2

        a = Kotoba::split(s)

        assert_equal a.join, s

        #puts Kotoba::to_integer("tunashima")
        #puts Kotoba::to_integer("tsunashima")

        assert Kotoba::is_kotoba_word("takeshi")

        assert Kotoba::is_kotoba_word("tsunasima")
        assert Kotoba::is_kotoba_word("tunashima")

        assert (not Kotoba::is_kotoba_word("dsfadf"))
        assert (not Kotoba::is_kotoba_word("takeshin"))
    end
end

#require 'pp'
#pp Kotoba::split(s2)
#
#puts Kotoba::is_kotoba_word("asdfadsg")
#puts Kotoba::is_kotoba_word(s2)

