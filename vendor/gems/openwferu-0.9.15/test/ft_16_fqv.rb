
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'flowtestbase'


class FlowTest16 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    def test_fqv_0
        dotest(\
'''<process-definition name="n" revision="0">
    <sequence>
        <set variable="x"><q>y</q></set>
        <print>x is "${x}"</print>
    </sequence>
</process-definition>''', 
'x is "y"')
    end

    def test_fqv_1
        dotest(\
'''<process-definition name="n" revision="0">
    <sequence>
        <set variable="x0"><q>y0</q></set>
        <set variable="x1"><v>x0</v></set>
        <print>x1 is "${x1}"</print>
    </sequence>
</process-definition>''', 
'x1 is "y0"')
    end

    def test_fqv_2
        dotest(\
'''<process-definition name="n" revision="0">
    <sequence>
        <set field="x0"><q>y0</q></set>
        <set variable="x1"><f>x0</f></set>
        <print>x1 is "${x1}"</print>
    </sequence>
</process-definition>''', 
'x1 is "y0"')
    end

end

