
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'openwfe/def'
require 'flowtestbase'


class FlowTest14b < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end


    #
    # TEST 0

    def test_subprocess_ref_0
    #def xxxx_subprocess_ref_0
        dotest(\
'''<process-definition name="subtest0" revision="0">

    <sequence>
        <subprocess ref="sub0" a="A" b="B" c="C" />
        <sub0 a="A" b="B" c="C" />
    </sequence>

    <process-definition name="sub0">
        <print>${a}${b}${c}</print>
    </process-definition>

</process-definition>''', '''ABC
ABC''')
    end


    #
    # TEST 1

    class SubTest1 < OpenWFE::ProcessDefinition
        def make

            sub1 "toto", :a => "A"

            process_definition :name => :sub1 do
                _print "${0} ${a}"
            end
        end
    end

    #def xxxx_sub_1
    def test_sub_1
        dotest(SubTest1, "toto A")
    end


    #
    # TEST 1b

    def test_subprocess_ref_1b
    #def xxxx_subprocess_ref_1b
        dotest(\
'''<process-definition name="subtest0" revision="0">

    <sequence>
        <subprocess ref="sub0" a="A">zero</subprocess>
        <sub0 a="A">rei</sub0>
    </sequence>

    <process-definition name="sub0">
        <print>${0} ${a}</print>
    </process-definition>

</process-definition>''', 
        """zero A
rei A""")
    end


    #
    # TEST 2

    class SubTest2 < OpenWFE::ProcessDefinition
        def make

            sequence do
                sub1 do 
                    "a"
                end
                sub1 "c", "d"
            end

            process_definition :name => :sub1 do
                _print "${0} ${1}"
            end
        end
    end

    #def xxxx_sub_2
    def test_sub_2
        dotest(SubTest2, """a 
c d""")
    end


    #
    # TEST 3

    class SubTest3 < OpenWFE::ProcessDefinition

        subprocess "c", "d", :ref => :sub1

        process_definition :name => :sub1 do
            _print "${0} ${1}"
        end
    end

    #def xxxx_sub_3
    def test_sub_3
        dotest(SubTest3, "c d")
    end

end

