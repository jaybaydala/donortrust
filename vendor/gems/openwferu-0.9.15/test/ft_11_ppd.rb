
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Tue Jan  2 13:14:37 JST 2007
#

require 'flowtestbase'
require 'openwfe/def'

include OpenWFE


class FlowTest11 < Test::Unit::TestCase
    include FlowTestBase

    #def setup
    #end

    #def teardown
    #end

    #
    # Test 0
    #

    class TestDefinition0 < ProcessDefinition
        def make
            process_definition :name => "test0", :revision => "0" do
                sequence do
                    _print do "a" end
                    _print { "b" }
                    _print "c"
                        #
                        # all these notations for nesting a string
                        # are allowed
                        #
                        # of course, the latter one is the nicest
                end
            end
        end
    end

    def test_ppd_0
    #def xxxx_ppd_0
        dotest(
            TestDefinition0,
            """a
b
c""")
    end


    #
    # Test 1
    #

    class TestDefinition1 < ProcessDefinition
        def make
            process_definition :name => "test1", :revision => "0" do
                sequence do
                    set :variable => "toto", :value => "nada"
                    _print "toto:${toto}"
                    set :field => "ftoto" do
                        "_${toto}__${r:'123'.reverse}"
                    end
                    _print { "ftoto:${f:ftoto}" }
                end
            end
        end
    end

    def test_ppd_1
    #def xxxx_ppd_1
        dotest(
            TestDefinition1,
            """
toto:nada
ftoto:_nada__321
            """.strip,
            true)
    end


    #
    # Test 2
    #

    class TestDefinition2 < ProcessDefinition
        def make
            process_definition :name => "test2", :revision => "0" do
                sequence do
                    set :variable => "toto", :value => "nada"
                    _if do
                        equals :variable_value => "toto", :other_value => "nada"
                        _print "toto:${toto}"
                        _print "not ok"
                    end
                end
            end
        end
    end

    def test_ppd_2
    #def xxxx_ppd_2
        dotest(
            TestDefinition2,
            "toto:nada",
            true)
    end


    #
    # Test 3
    #

    class TestDefinition3 < ProcessDefinition
        def make
            process_definition :name => "test3", :revision => "0" do
                sequence do
                    subprocess :ref => "sub0", :var0 => "a"
                    sub0 :var0 => "b"
                end
                process_definition :name => "sub0" do
                    _print "var0 is '${var0}'"
                end
            end
        end
    end

    def test_ppd_3
    #def xxxx_ppd_3

        #puts
        #puts TestDefinition3.do_make(ExpressionMap.new(nil, nil)).to_code_s
        #puts
        #puts TestDefinition3.do_make(ExpressionMap.new(nil, nil)).to_s

        dotest(
            TestDefinition3,
            """var0 is 'a'
var0 is 'b'""")
    end


    #
    # Test 4
    #

    class TestDefinition4 < ProcessDefinition
        def make
            process_definition :name => "test4", :revision => "0" do
                sequence do
                    sequence do
                        _print "a"
                    end
                    sequence do
                        _print "b"
                    end
                end
            end
        end
    end

    CODE4 = """
process_definition :name => 'test4', :revision => '0' do
    sequence do
        sequence do
            _print do
                'a'
            end
        end
        sequence do
            _print do
                'b'
            end
        end
    end
end
    """.strip

    def test_ppd_4
    #def xxxx_ppd_4

        s = TestDefinition4.do_make.to_code_s

        #puts
        #puts s
        #puts
        #puts TestDefinition4.do_make(ExpressionMap.new(nil, nil)).to_s

        dotest(
            TestDefinition4,
            """
a
b
            """.strip,
            0.300)

        assert \
            s == CODE4,
            "nested sequences test failed (4)"
    end


    #
    # Test 5
    #

    class TestDefinition5 < ProcessDefinition
        def make
            process_definition :name => "test5", :revision => "0" do
                sequence do
                    sequence do
                        _print { "a" }
                    end
                    sequence do
                        _print { "b" }
                    end
                end
            end
        end
    end

    CODE5 = """
process_definition :name => 'test5', :revision => '0' do
    sequence do
        sequence do
            _print do
                'a'
            end
        end
        sequence do
            _print do
                'b'
            end
        end
    end
end
    """.strip

    def test_ppd_5
    #def xxxx_ppd_5

        s = TestDefinition5.do_make.to_code_s

        #puts
        #puts s
        #puts
        #puts TestDefinition5.do_make(ExpressionMap.new(nil, nil)).to_s

        dotest(
            TestDefinition5,
            """a
b""")

        assert \
            s == CODE5,
            "nested sequences test failed (5)"
    end


    #
    # Test 6
    #

    class TestDefinition6 < ProcessDefinition

        def initialize (count)
            super()
            @count = count
        end

        def make
            process_definition :name => "test6", :revision => "0" do
                sequence do
                    @count.times do |i|
                        _print i
                    end
                end
            end
        end
    end

    def test_ppd_6
    #def xxxx_ppd_6
        dotest(
            TestDefinition6.new(3),
            """0
1
2""")
    end


    #
    # Test 7
    #

    class TestDefinition7 < ProcessDefinition
        def make
            _process_definition :name => "test7", :revision => "0" do
                _sequence do
                    _print "a"
                    _print "b"
                end
            end
        end
    end

    def test_ppd_7
    #def xxxx_ppd_7
        dotest(
            TestDefinition7,
            """a
b""")
    end


    #
    # Test 8
    #

    class TestDefinition8 < ProcessDefinition
        def make
            process_definition :name => "test8", :revision => "0" do
                toto
                process_definition :name => "toto" do
                    _print "toto"
                end
            end
        end
    end

    def test_ppd_8
    #def xxxx_ppd_8
        dotest(
            TestDefinition8,
            "toto")
    end


    #
    # Test 9
    #

    class TestDefinition9 < ProcessDefinition
        def make
            process_definition :name => "test9", :revision => "0" do
                _toto
                process_definition :name => "toto" do
                    _print "toto"
                end
            end
        end
    end

    def test_ppd_9
    #def xxxx_ppd_9
        dotest(
            TestDefinition9,
            "toto")
    end


    #
    # Test 10
    #

    class TestDefinition10 < ProcessDefinition
        def make
            process_definition :name => "test10", :revision => "0" do
                sequence do
                    participant :ref => "toto_underscore"
                    _toto_underscore
                    toto_underscore
                end
            end
        end
    end

    def test_ppd_10
    #def xxxx_ppd_10

        @engine.register_participant(:toto_underscore) do |workitem|
            @tracer << "toto\n"
        end

        dotest(
            TestDefinition10,
            """toto
toto
toto""")
    end


    #
    # Test 11
    #

    class TestDefinition11 < ProcessDefinition
        def make
            sequence do
                [ :b, :b, :b ].each do |p|
                    participant p
                end
                participant "b"
            end
        end
    end

    #def xxxx_ppd_11
    def test_ppd_11

        @engine.register_participant(:b) do |workitem|
            @tracer << "b\n"
        end

        dotest(
            TestDefinition11,
            """b
b
b
b""")
    end

    #
    # Test 12
    #

    class TestDefinition12 < OpenWFE::ProcessDefinition
        sequence do
            _print "main"
            sub_x
        end
        process_definition :name => "sub-x" do
            _print "sub"
        end
    end

    def test_prog_12
        dotest(TestDefinition12, "main\nsub")
    end


    #
    # Test 13
    #

    class TestDefinition13 < OpenWFE::ProcessDefinition
    end

    def xxxx_prog_13
    #def test_prog_13
        dotest(TestDefinition13, "")
    end

end

