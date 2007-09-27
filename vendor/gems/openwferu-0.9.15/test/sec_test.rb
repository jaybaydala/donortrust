
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Tue Jan  2 13:14:37 JST 2007
#

require 'test/unit'

require 'openwfe/workitem'
require 'openwfe/engine/engine'


class SecTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    #def xxxx_sec_0
    def test_sec_0

        engine = OpenWFE::Engine.new

        engine.ac[:ruby_eval_allowed] = true

        def0 = \
'''<process-definition name="" revision="0">
    <sequence>
        <!--
        <reval>puts "ok"</reval>
        <reval>self.ac[:ruby_eval_allowed] = false</reval>
        <reval>puts self.ac[:ruby_eval_allowed]</reval>
        <reval>puts "ok after"</reval>
        -->
        <reval>File.open("nada.txt") do |f| f.write("nada"); end</reval>
    </sequence>
</process-definition>''' 

        dotest(engine, def0)

        assert(
            OpenWFE::grep(
                "Insecure operation - initialize", 
                "logs/openwferu.log").size > 0)

        def1 =
'''<process-definition name="" revision="0">
    <sequence>
        <reval>
            class Object
                def my_name
                    "toto"
                end
            end
            "stringobject".my_name
        </reval>
    </sequence>
</process-definition>''' 

        dotest(engine, def1)

        assert((
            OpenWFE::grep "undefined method `my_name' for \"stringobject\":String", 
            "logs/openwferu.log").size > 0)

        def2 =
'''<process-definition name="" revision="0">
    <sequence>
        <reval>
            <![CDATA[
            class << self.ac["engine"]
                def is_secure?
                    true
                end
            end
            self.ac["engine"].is_secure?
            ]]>
        </reval>
    </sequence>
</process-definition>''' 

        dotest(engine, def2)

        def3 =
'''<process-definition name="" revision="0">
    <sequence>
        <reval>self.ac[:ruby_eval_allowed] = false</reval>
        <reval>puts self.ac[:ruby_eval_allowed]</reval>
    </sequence>
</process-definition>''' 

        dotest(engine, def3)

        assert OpenWFE::grep(
            "evaluation of ruby code is not allowed", "logs/openwferu.log")

        engine.stop
    end

    def test_sec_1

        value = nil

        engine = OpenWFE::Engine.new

        engine.register_participant(:toto) do |workitem|
            value = "#{workitem.attributes.size}_#{workitem.f}"
        end

        def0 =
'''<process-definition name="" revision="0">
    <sequence>
        <set field="f" value="${ruby:5*7}" />
        <toto/>
    </sequence>
</process-definition>''' 

        engine.launch(OpenWFE::LaunchItem.new(def0))

        sleep 0.100

        assert_equal value, "4_"

        engine.ac[:ruby_eval_allowed] = true

        engine.launch(OpenWFE::LaunchItem.new(def0))

        sleep 0.100

        assert_equal value, "4_35"

        engine.stop
    end

    protected

        def dotest (engine, def_or_li)

            li = if def_or_li.is_a?(OpenWFE::LaunchItem)
                def_or_li
            else
                OpenWFE::LaunchItem.new(def_or_li)
            end
            
            engine.launch(li)

            sleep 0.100
        end

end

