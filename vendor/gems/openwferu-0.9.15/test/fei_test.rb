
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'test/unit'
require 'rutest_utils'
#require 'openwfe/owfe'
require 'openwfe/workitem'
require 'openwfe/flowexpressionid'
require 'openwfe/rudefinitions'


class FeiTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    def test_equality

        fei1 = new_fei()
        fei2 = new_fei()

        assert \
            fei1.object_id != fei2.object_id, \
            "feis are not two distinct feis"
        assert \
            fei1.hash == fei2.hash, \
            "feis do not have the same hash"
        assert \
            fei1 == fei2, \
            "feis are not equals (==)"
        assert \
            fei1.eql?(fei2), \
            "feis are not equals (eql?)"
    end

    def test_inequality

        fei1 = new_fei()

        fei2 = new_fei()
        fei2.expression_name = OpenWFE::EN_ENVIRONMENT

        assert \
            fei1.object_id != fei2.object_id, \
            "feis are not two distinct feis"
        assert \
            fei1.hash != fei2.hash, \
            "feis do have the same hash"
        assert \
            fei1 != fei2, \
            "feis are equals (==)"
        assert \
            (not fei1.eql?(fei2)), \
            "feis are equals (eql?)"
    end

    def test_in_hash
        h = Hash.new()

        fei1 = new_fei()
        fei2 = new_fei()

        h[fei1] = 'one'
        h[fei2] = 'two'

        #puts_hash(h)
        #puts "fei1 :   #{fei1.to_debug_s}"
        #puts "fei2 :   #{fei2.to_debug_s}"

        assert \
            h.size() == 1,
            "h should have one entry"
        assert \
            h[fei1] == h[fei2],
            "both keys should point to the same thing"
        assert \
            h[fei1] == 'two',
            "value should be 'two' (fei1)"
        assert \
            h[fei2] == 'two',
            "value should be 'two' (fei2)"
    end

    def test_dup
        fei0 = new_fei()
        fei1 = fei0.dup()

        assert \
            fei0 == fei1,
            "feis should be equal"

        fei1.expression_name = OpenWFE::EN_ENVIRONMENT

        assert \
            fei0 != fei1, 
            "feis should not be equal"
    end

    def test_parse_unparse
        fei0 = new_fei()
        s = fei0.to_s
        fei1 = OpenWFE::FlowExpressionId.to_fei(s)
        fei2 = OpenWFE::FlowExpressionId.from_s(s)

        puts "\n#{s}\n#{fei1.to_s}" if fei0 != fei1

        assert_equal fei0, fei1
        assert_equal fei1, fei2
    end

    def test_parent_wfid

        fei = new_fei

        assert \
            fei.parent_workflow_instance_id == "123456",
            "failure 0"

        fei.workflow_instance_id = "123456.0.0"

        assert \
            fei.parent_workflow_instance_id == "123456",
            "failure 1"
    end

    #def test_to_fei
    #    fei = new_fei
    #    wi = OpenWFE::InFlowItem.new
    #    wi.last_expression_id = fei
    #    assert_nil OpenWFE::to_fei(nil)
    #    assert_equal fei, OpenWFE::to_fei(fei)
    #    assert_equal fei, OpenWFE::to_fei(wi)
    #    assert_equal fei, OpenWFE::to_fei(fei.to_s)
    #end

    protected

        def puts_hash (h)
            puts
            h.each do |k, v|
                puts "   * '#{k.to_debug_s}' --> '#{v}'"
            end
            puts
        end

end

