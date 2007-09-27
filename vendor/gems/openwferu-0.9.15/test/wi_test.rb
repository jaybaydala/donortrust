
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#

require 'test/unit'
require 'openwfe/workitem'
require 'openwfe/util/dollar'

include OpenWFE


class WiTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    def test_lookup_0

        wi = InFlowWorkItem.new()
        wi.attributes = {
            "field0" => "value0",
            "field1" => [ 0, 1, 2, 3, [ "a", "b", "c" ]],
            "field2" => {
                "a" => "AA", 
                "b" => "BB", 
                "c" => [ "C0", "C1", "C3" ]
            },
            "field3" => 3,
            "field99" => nil
        }

        assert wi.lookup_attribute("field3") == 3
        assert wi.lookup_attribute("field1.1") == 1
        assert wi.lookup_attribute("field1.4.1") == "b"
        assert wi.lookup_attribute("field2.c.1") == "C1"
        assert wi.lookup_attribute("field4") == nil
        assert wi.lookup_attribute("field4.2") == nil
        assert wi.lookup_attribute("field99") == nil
        assert wi.lookup_attribute("field99.9") == nil

        assert wi.has_attribute?("field4") == false
        assert wi.has_attribute?("field4.2") == false
        assert wi.has_attribute?("field99") == true
        assert wi.has_attribute?("field99.9") == false

        text = "value is '${f:field2.c.1}'"
        text = OpenWFE::dosub(text, nil, wi)
        assert text == "value is 'C1'"

        # setting attributes

        wi.set_attribute("field2.a", 42)
        wi.set_attribute("field99", "f99")

        assert wi.lookup_attribute("field2.a") == 42
        assert wi.lookup_attribute("field99") == "f99"
    end

end

