
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#

require 'openwfe/def'

require 'flowtestbase'


class FlowTest64 < Test::Unit::TestCase
    include FlowTestBase

    #def teardown
    #end

    #def setup
    #end


    #
    # TEST 0

    class Box

        attr_reader :content

        def initialize (content)
            @content = content
        end
    end

    class Test0 < ProcessDefinition
        sequence do
            participant :alpha
            participant :bravo
            _print "ok"
        end
    end

    #def xxxx_0
    def test_0

        box1 = nil

        @engine.register_participant :alpha do |workitem|
            # nothing
        end

        @engine.register_participant :bravo do |workitem|

            box1 = OpenWFE::fulldup(workitem.box)
        end

        box0 = Box.new("books")

        li = LaunchItem.new(Test0)
        li.box = box0

        dotest(li, "ok")

        assert_equal box1.content, "books"
        assert_not_equal box1.object_id, box0.object_id
    end

end

