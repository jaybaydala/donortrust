
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Sun Oct 29 16:18:25 JST 2006
#

require 'test/unit'

require 'openwfe/engine/engine'
require 'openwfe/participants/participants'

#
# testing misc things
#

class ParticipantTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    def test_lookup_participant

        engine = OpenWFE::Engine.new
        engine.register_participant :toto, NullParticipant

        p = engine.get_participant "toto"
        assert_kind_of NullParticipant, p

        p = engine.get_participant :toto
        assert_kind_of NullParticipant, p
    end

end
