
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'test/unit'
require 'openwfe/expressions/raw_prog'


class RawProgTest < Test::Unit::TestCase

    DEBUG = false

    #def setup
    #end

    #def teardown
    #end

    XML_DEF = """
<process-definition name='test0' revision='0'>
  <sequence>
    <participant ref='a'/>
    <participant ref='b'/>
  </sequence>
</process-definition>""".strip


    #
    # TEST 0
    #

    class TestDefinition < OpenWFE::ProcessDefinition
        def make
            process_definition :name => "test0", :revision => "0" do
                sequence do
                    participant :ref => "a"
                    participant :ref => "b"
                end
            end
        end
    end

    def test_prog_0

        s = TestDefinition.new().make.to_s

        puts s if DEBUG

        assert \
            s == XML_DEF,
            "parsing failed (0)"
    end

    def test_prog_0b

        s = TestDefinition.do_make.to_s

        puts s if DEBUG

        assert \
            s == XML_DEF,
            "parsing failed (0b)"
    end


    #
    # TEST 1
    #

    def test_prog_1

        pg = OpenWFE::ProcessDefinition.new()

        class << pg
            def my_proc
                process_definition :name => "test0", :revision => "0" do
                    sequence do
                        participant :ref => "a"
                        participant :ref => "b"
                    end
                end
            end
        end
        pdef = pg.my_proc
        s = pdef.to_s

        puts s if DEBUG

        assert \
            s == XML_DEF,
            "parsing failed (1)"
    end


    #
    # TEST 2
    #

    class TestDefinition2 < OpenWFE::ProcessDefinition
        def make
            process_definition :name => "test2", :revision => "0" do
                sequence do
                    set :field => "toto" do
                        "nada"
                    end
                    participant :ref => "b"
                end
            end
        end
    end

    XML_DEF2 = """
<process-definition name='test2' revision='0'>
  <sequence>
    <set field='toto'>nada</set>
    <participant ref='b'/>
  </sequence>
</process-definition>""".strip

    def test_prog_2

        s = TestDefinition2.do_make.to_s

        puts s if DEBUG

        assert \
            s == XML_DEF2,
            "parsing failed (2)"

        #puts
        #puts TestDefinition2.do_make.to_code_s
    end


    #
    # TEST 3
    #

    class TestDefinition3 < OpenWFE::ProcessDefinition
        def make
            process_definition :name => "test3", :revision => "0" do
                _if do
                    equals :field_value => "nada", :other_value => "surf"
                    participant :ref => "b"
                end
            end
        end
    end

    XML_DEF3 = """
<process-definition name='test3' revision='0'>
  <if>
    <equals field-value='nada' other-value='surf'/>
    <participant ref='b'/>
  </if>
</process-definition>""".strip

    CODE_DEF3 = """
process_definition :name => 'test3', :revision => '0' do
    _if do
        equals :field_value => 'nada', :other_value => 'surf'
        participant :ref => 'b'
    end
end""".strip

    def test_prog_3

        s = TestDefinition3.do_make.to_s

        puts s if DEBUG

        assert \
            s == XML_DEF3,
            "parsing failed (3)"

        #puts
        #puts TestDefinition3.do_make.to_code_s

        assert \
            TestDefinition3.do_make.to_code_s == CODE_DEF3,
            "to_code_s() not working properly (3)"

        r = OpenWFE::SimpleExpRepresentation.from_xml(s)
        #puts r.class.name
        #puts r.to_code_s

        assert_equal r.to_code_s, CODE_DEF3
    end


    #
    # TEST 4
    #

    class TestDefinition4 < OpenWFE::ProcessDefinition
        def make
            process_definition :name => "test4", :revision => "0" do
                sequence do
                    3.times { participant :ref => "b" }
                end
            end
        end
    end

    CODE_DEF4 = """
process_definition :name => 'test4', :revision => '0' do
    sequence do
        participant :ref => 'b'
        participant :ref => 'b'
        participant :ref => 'b'
    end
end""".strip

    def test_prog_4

        #puts
        #puts TestDefinition4.do_make.to_s
        #puts
        #puts TestDefinition4.do_make.to_code_s

        assert \
            TestDefinition4.do_make.to_code_s == CODE_DEF4,
            "to_code_s() not working properly (4)"
    end


    #
    # TEST 4b
    #

    class TestDefinition4b < OpenWFE::ProcessDefinition
        def make
            sequence do
                [ :b, :b, :b ].each do |p|
                    participant p
                end
            end
        end
    end

    CODE_DEF4b = """
process_definition :name => 'TestDefinition4b', :revision => '0' do
    sequence do
        participant do
            'b'
        end
        participant do
            'b'
        end
        participant do
            'b'
        end
    end
end""".strip

    def test_prog_4b

        #puts
        #puts TestDefinition4.do_make.to_s
        #puts
        #puts TestDefinition4b.do_make.to_code_s

        assert \
            TestDefinition4b.do_make.to_code_s == CODE_DEF4b,
            "to_code_s() not working properly (4b)"
    end


    #
    # TEST 5
    #

    class TestDefinition5 < OpenWFE::ProcessDefinition
        def make
            sequence do
                participant :ref => :toto
                sub0
            end
            process_definition :name => "sub0" do
                nada
            end
        end
    end

    CODE_DEF5 = """
process_definition :name => 'Test', :revision => '5' do
    sequence do
        participant :ref => 'toto'
        sub0
    end
    process_definition :name => 'sub0' do
        nada
    end
end""".strip

    def test_prog_5

        #puts
        #puts TestDefinition5.do_make.to_s
        #puts
        #puts TestDefinition5.do_make.to_code_s

        assert \
            TestDefinition5.do_make.to_code_s == CODE_DEF5,
            "to_code_s() not working properly (5)"
    end


    #
    # TEST 6
    #

    class TestDefinition60 < OpenWFE::ProcessDefinition
        def make
            sequence do
                participant :ref => :toto
                nada
            end
        end
    end

    CODE_DEF6 = """
process_definition :name => 'Test', :revision => '60' do
    sequence do
        participant :ref => 'toto'
        nada
    end
end""".strip

    def test_prog_6

        #puts
        #puts TestDefinition60.do_make.to_s
        #puts
        #puts TestDefinition60.do_make.to_code_s

        assert \
            TestDefinition60.do_make.to_code_s == CODE_DEF6,
            "to_code_s() not working properly (6)"
    end


    #
    # TEST 7
    #

    class TestDefinitionSeven < OpenWFE::ProcessDefinition
        def make
            participant :ref => :toto
        end
    end

    CODE_DEF7 = """
process_definition :name => 'TestDefinitionSeven', :revision => '0' do
    participant :ref => 'toto'
end""".strip

    A_DEF7 = [
        "process-definition",
        {"name"=>"TestDefinitionSeven", "revision"=>"0"},
        [
            ["participant", {"ref"=>"toto"}, []]
        ]
    ]

    def test_prog_7

        #puts
        #puts TestDefinition7.do_make.to_s
        #puts
        #puts TestDefinition7.do_make.to_code_s

        assert_equal TestDefinitionSeven.do_make.to_code_s, CODE_DEF7

        assert_equal TestDefinitionSeven.do_make.to_a, A_DEF7
    end

    #
    # TEST 8
    #

    def do_test(class_name, pdef)
        result = eval """
            class #{class_name} < OpenWFE::ProcessDefinition
                def make
                    participant 'nada'
                end
            end
            #{class_name}.do_make
        """
        assert_equal result.attributes['name'], pdef[0]
        assert_equal result.attributes['revision'], pdef[1]
    end

    def test_process_names
        do_test("MyProcessDefinition_10", ["MyProcess", "10"])
        do_test("MyProcessDefinition10", ["MyProcess", "10"])
        do_test("MyProcessDefinition1_0", ["MyProcess", "1.0"])
        do_test("MyProcessThing_1_0", ["MyProcessThing", "1.0"])
    end


    #
    # TEST 9
    #

    class TestDefinition9 < OpenWFE::ProcessDefinition
        def make
            description "this is my process"
            sequence do
                participant :ref => :toto
            end
        end
    end

    CODE_DEF9 = """
process_definition :name => 'Test', :revision => '60' do
    description 'this is my process'
    sequence do
        participant :ref => 'toto'
        nada
    end
end""".strip

    def xxxx_prog_9
    #def test_prog_9

        #puts
        #puts TestDefinition60.do_make.to_s
        puts
        puts TestDefinition9.do_make.to_code_s

        assert \
            TestDefinition9.do_make.to_code_s == CODE_DEF9,
            "to_code_s() not working properly (9)"
    end

end

