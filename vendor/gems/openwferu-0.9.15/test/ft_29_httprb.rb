
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'openwfe/def'
require 'openwfe/workitem'
require 'openwfe/worklist/storeparticipant'

require 'flowtestbase'


class FlowTest29 < Test::Unit::TestCase
    include FlowTestBase

    #def teardown
    #end

    def setup
        super
        @engine.ac[:remote_definitions_allowed] = true
    end

    DEFHOST = "http://openwferu.rubyforge.org/defs"

    #
    # TEST 0

    #def xxxx_httprb_0
    def test_httprb_0

        li = OpenWFE::LaunchItem.new
        li.wfdurl = "#{DEFHOST}/testdef.rb"

        dotest(
            li, 
            """a
b
c""")
    end


    #
    # TEST 1

    class MainDefinition1 < OpenWFE::ProcessDefinition
        def make
            sequence do
                _print "A"
                subprocess :ref => "#{DEFHOST}/testdef.rb"
                _print "C"
            end
        end
    end

    #def xxxx_httprb_1
    def test_httprb_1
        dotest(
            MainDefinition1, 
            """A
a
b
c
C""")
    end


    #
    # TEST 2

    class MainDefinition2 < OpenWFE::ProcessDefinition
        def make
            sequence do
                _print "-1"
                subprocess :ref => "#{DEFHOST}/testdef.xml"
                _print "3"
            end
        end
    end

    #def xxxx_httprb_2
    def test_httprb_2
        dotest(
            MainDefinition2, 
            """-1
0
1
2
3""")
    end


    #
    # TEST 3

    #def xxxx_httprb_3
    def test_httprb_3

        @engine.ac.delete(:remote_definitions_allowed)
            #
            # relocking

        li = OpenWFE::LaunchItem.new
        li.wfdurl = "#{DEFHOST}/testdef.rb"

        e = nil

        begin
            dotest(li, "")
        rescue Exception => e
        end

        #puts e

        assert_not_nil e
        assert_equal e.to_s, "loading remote definitions is not allowed"
    end

end

