
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Sun Oct 29 16:18:25 JST 2006
#

require 'test/unit'

require 'openwfe/workitem'
require 'openwfe/flowexpressionid'

require 'rutest_utils'


#
# testing fei.to_h and wi.to_h
#

class HashTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    def test_fei_to_h

        fei0 = new_fei
        h = fei0.to_h
        fei1 = OpenWFE::FlowExpressionId.from_h(h)

        assert_equal fei0, fei1
    end

    def test_wi_to_h

        wi0 = OpenWFE::InFlowWorkItem.new
        wi0.fei = new_fei

        h = wi0.to_h
        #require 'pp'; pp h

        wi1 = OpenWFE::InFlowWorkItem.from_h(h)

        assert_equal wi0.fei, wi1.fei
        assert_equal wi0.attributes.length, wi1.attributes.length

        wi2 = OpenWFE::workitem_from_h(h)

        assert_equal wi0.fei, wi2.fei
        assert_equal wi0.attributes.length, wi2.attributes.length
    end

    def test_any_from_h

        li = OpenWFE::LaunchItem.new()
        li.workflow_definition_url = "http://www.openwfe.org/nada"
        li.price = "USD 12"
        li.customer = "Captain Nemo"

        h = li.to_h
        #require 'pp'; pp h

        li1 = OpenWFE::workitem_from_h(h)

        assert li1.is_a?(OpenWFE::LaunchItem)
        assert_equal li1.price, "USD 12"
        assert_equal li1.attributes.size, 3
    end

end
