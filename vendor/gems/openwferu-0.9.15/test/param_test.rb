
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Tue Jan  2 13:14:37 JST 2007
#

require 'flowtestbase'
require 'openwfe/def'
require 'openwfe/workitem'
require 'openwfe/exceptions'


class ParameterTest < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    #
    # test 0

    def test_param_0

        definition = '''
<process-definition name="reqtest" revision="0">
    <parameter field="address"/>
    <print>${f:address}</print>
</process-definition>'''.strip

        li = OpenWFE::LaunchItem.new(definition)

        e = nil
        
        begin
            @engine.launch(li)
        rescue Exception => e
            #puts e
            #puts OpenWFE::exception_to_s(e)
        end

        assert_equal \
            e.to_s,
            "field 'address' is missing"

        # second round

        li = OpenWFE::LaunchItem.new(definition)
        li.address = "rose garden 4"

        #require 'pp' ; pp li

        fei = nil
        e = nil
        
        begin
            fei = @engine.launch(li)
        rescue Exception => e
            #puts e
            #puts OpenWFE::exception_to_s(e)
        end

        assert_nil e

        sleep 0.200
            # let the flow terminate on its own
    end


    #
    # test 1

    class TestParam1 < OpenWFE::ProcessDefinition
        
        param :field => "customer"
        param :field => "address"

        _print "#{f:customer},  #{f:address}"
    end

    def test_param_1

        li = OpenWFE::LaunchItem.new(TestParam1)

        e = nil
        
        begin
            @engine.launch(li)
        rescue Exception => e
            #puts e
            #puts OpenWFE::exception_to_s(e)
        end

        assert_equal \
            e.to_s,
            "field 'customer' is missing"

        li = OpenWFE::LaunchItem.new(TestParam1)
        li.customer = "bauhaus"
        li.address = "rose garden 4"

        e = nil
        
        begin
            @engine.launch(li)
        rescue Exception => e
            #puts e
            #puts OpenWFE::exception_to_s(e)
        end

        assert_nil e
    end


    #
    # test 2

    class TestParam2 < OpenWFE::ProcessDefinition
        
        param :field => "address", :default => "(unknown address)"

        sequence do
            #pp_workitem
            _print "${f:address}"
        end
    end

    def test_param_2

        li = OpenWFE::LaunchItem.new(TestParam2)

        e = nil

        begin
            @engine.launch(li)
        rescue Exception => e
            #puts e
            #puts OpenWFE::exception_to_s(e)
        end

        sleep 0.200

        assert_nil e
        assert_equal @tracer.to_s, "(unknown address)"
    end


    #
    # test 3

    class TestParam3 < OpenWFE::ProcessDefinition
        
        param :field => :address, :type => :string

        sequence do
            #pp_workitem
            _print "${f:address}"
        end
    end

    def test_param_3

        li = OpenWFE::LaunchItem.new(TestParam3)
        li.address = 3

        e = nil

        begin
            @engine.launch(li)
        rescue Exception => e
            #puts e
            #puts OpenWFE::exception_to_s(e)
        end

        sleep 0.200

        # well, I should maybe refactor the test into a method

        assert_nil e
        assert_equal @tracer.to_s, "3"
    end


    #
    # test 4

    class TestParam4 < OpenWFE::ProcessDefinition
        
        param :field => :zip, :type => :integer

        _print "${f:zip}"
    end

    def test_param_4

        li = OpenWFE::LaunchItem.new(TestParam4)
        li.zip = "Colorado"

        e = nil

        begin
            @engine.launch(li)
        rescue Exception => e
            #puts e
            #puts OpenWFE::exception_to_s(e)
        end

        assert_not_nil e
        assert_equal e.to_s, 'invalid value for Integer: "Colorado"'
    end


    #
    # test 5

    def test_param_5

        definition = '''
<process-definition name="paramtest" revision="5">
    <parameter field="phone" match="^[0-9]{3}-[0-9]{3}-[0-9]{4}$" />
    <print>${field:phone}</print>
</process-definition>'''.strip

        li = OpenWFE::LaunchItem.new(definition)

        e = nil
        
        begin
            @engine.launch(li)
        rescue Exception => e
            #puts e
            #puts OpenWFE::exception_to_s(e)
        end

        assert_equal e.to_s, "field 'phone' is missing"
        assert_equal e.class, OpenWFE::ParameterException

        # second round

        li = OpenWFE::LaunchItem.new(definition)
        li.phone = "4444-333-4444"

        #require 'pp' ; pp li

        e = nil
        
        begin
            @engine.launch(li)
        rescue Exception => e
            #puts e
            #puts OpenWFE::exception_to_s(e)
        end

        assert_not_nil e
        assert_equal e.to_s, "value of field 'phone' doesn't match"
    end


    #
    # test 6

    class TestParam6 < OpenWFE::ProcessDefinition
        
        param :field => "customer_type", :default => "2", :type => "int"

        _print "#{f:customer},  #{f:address}"
    end

    def test_param_1

        li = OpenWFE::LaunchItem.new(TestParam6)

        e = nil
        begin
            @engine.pre_launch_check(li)
        rescue Exception => e
            #puts e
            #puts OpenWFE::exception_to_s(e)
        end

        #require 'pp'; pp li

        assert_nil e
        assert li.customer_type
        assert li.customer_type == 2
    end

end

