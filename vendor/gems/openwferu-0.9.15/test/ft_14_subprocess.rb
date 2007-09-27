
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'flowtestbase'


class FlowTest14 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    def test_subprocess_ref_0
        dotest(\
'''<process-definition name="subtest0" revision="0">

    <subprocess ref="sub0" />

    <process-definition name="sub0">
        <print>ok</print>
    </process-definition>

</process-definition>''', 'ok')
    end

    def test_subprocess_ref_1
        dotest(\
'''<process-definition name="subtest0" revision="0">

    <sequence>
        <subprocess ref="sub0" />
        <subprocess ref="sub0" />
    </sequence>

    <process-definition name="sub0">
        <print>ok</print>
    </process-definition>

</process-definition>''', '''ok
ok''')
    end

    def test_subprocess_ref_2
        dotest(\
'''<process-definition name="subtest0" revision="0">

    <sequence>
        <sub0 />
        <print>after</print>
    </sequence>

    <process-definition name="sub0">
        <print>ok</print>
    </process-definition>

</process-definition>''', '''ok
after''')
    end

    def test_subprocess_ref_3
        dotest(\
'''<process-definition name="subtest0" revision="0">

    <sequence>
        <set variable="v" value="out" />
        <sub0 />
        <print>after : ${v}</print>
    </sequence>

    <process-definition name="sub0">
        <sequence>
            <set variable="v" value="in" />
            <print>ok : ${v}</print>
        </sequence>
    </process-definition>

</process-definition>''', '''ok : in
after : out''')
    end

end

