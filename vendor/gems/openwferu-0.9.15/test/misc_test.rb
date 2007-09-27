
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Sun Oct 29 16:18:25 JST 2006
#

require 'test/unit'
require 'rexml/document'

require 'openwfe/utils'
require 'openwfe/expressions/fe_define'
require 'openwfe/expressions/expressionmap'

#
# testing misc things
#

class MiscTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    def test_starts_with
        assert \
            OpenWFE::starts_with("//a", "//")
        assert \
            (not OpenWFE::starts_with("/a", "//"))
    end

    def test_ends_with
        assert \
            OpenWFE::ends_with("c'est la fin", "fin")
    end

    def test_ensure_for_filename

        assert OpenWFE::ensure_for_filename("abc") == "abc"
        assert OpenWFE::ensure_for_filename("a/c") == "a_c"
        assert OpenWFE::ensure_for_filename("a\\c") == "a_c"
        assert OpenWFE::ensure_for_filename("a*c") == "a_c"
        assert OpenWFE::ensure_for_filename("a+?") == "a__"
        assert OpenWFE::ensure_for_filename("a b") == "a_b"
    end

    def test_clean_path

        assert OpenWFE::clean_path("my//file/path") == "my/file/path"
        assert OpenWFE::clean_path("my//file//path") == "my/file/path"
    end

    def test_stu
        assert_equal "a_b_c", OpenWFE::stu("a b c")
    end

    def test_dup
        a0 = A.new
        a0.a = 1
        a0.b = 2
        a1 = OpenWFE::fulldup(a0)

        #puts a0
        #puts a1
        
        assert \
            a0.equals(a1),
            "dup() utility not working"
    end

    def test_dup_1
        d = REXML::Document.new("<document/>")
        d1 = OpenWFE::fulldup(d)
        assert d.object_id != d1.object_id
    end

    def test_grep_0
        assert OpenWFE::grep("sputnik", "Rakefile").empty?
        assert_equal OpenWFE::grep("Mettraux", "Rakefile").size, 5

        OpenWFE::grep "Mettraux", "Rakefile" do |line|
            assert_match "Mettraux", line
        end
    end

    private
    
        class A
            attr_accessor :a, :b

            def equals (other)
                return false if not other.kind_of?(A)
                return (self.a == other.a and self.b == other.b)
            end

            def to_s
                "A : a='#{a}', b='#{b}'"
            end
        end

end
