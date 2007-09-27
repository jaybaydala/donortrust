
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Tue Jan  2 13:14:37 JST 2007
#

require 'flowtestbase'


$s = ""
0.upto(9) do |i|
    $s << i.to_s
    $s << "\n"
end
$s = $s.strip()


class FlowTest10 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    def test_loop_0
        dotest(
'<process-definition name="'+name_of_test+'''" revision="0">
    <sequence>
        <reval>$i = 0</reval>
        <loop>
            <print>${r:$i}</print>
            <reval>$i = $i + 1</reval>
            <if>
                <equals value="${r:$i}" other-value="10" />
                <break/>
            </if>
        </loop>
    </sequence>
</process-definition>''', 
        $s,
        true)
    end

    #def xxxx_loop_1
    def test_loop_1
        dotest(
'<process-definition name="'+name_of_test+'''" revision="0">
    <sequence>
        <reval>$i = 0</reval>
        <loop>
            <print>${r:$i}</print>
            <reval>$i = $i + 1</reval>
            <if rtest="$i == 10">
                <break/>
            </if>
        </loop>
    </sequence>
</process-definition>''', 
        $s,
        true)
    end

    #def xxxx_loop_2
    def test_loop_2
        dotest(
'<process-definition name="'+name_of_test+'''" revision="0">
    <sequence>
        <reval>$i = 0</reval>
        <loop>
            <print>${r:$i}</print>
            <reval>$i = $i + 1</reval>
            <break if="${r:$i} == 10" />
        </loop>
    </sequence>
</process-definition>''', 
        $s,
        true)
    end

    #def xxxx_loop_3
    def test_loop_3
        dotest(
'<process-definition name="'+name_of_test+'''" revision="0">
    <sequence>
        <reval>$i = 0</reval>
        <loop>
            <print>${r:$i}</print>
            <reval>$i = $i + 1</reval>
            <break if="${r:$i == 10}" />
        </loop>
    </sequence>
</process-definition>''', 
        $s,
        true)
    end

    #def xxxx_loop_4
    def test_loop_4
        dotest(
'<process-definition name="'+name_of_test+'''" revision="0">
    <sequence>
        <reval>$i = 0</reval>
        <loop>
            <print>${r:$i}</print>
            <reval>$i = $i + 1</reval>
            <break rif="$i == 10" />
        </loop>
    </sequence>
</process-definition>''', 
        $s,
        true)
    end

end

