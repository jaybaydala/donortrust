
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#

require 'test/unit'

require 'openwfe/utils'


class FullDupTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    class MyClass

        attr_reader :name

        def initialize (name)
            @name = name
        end
    end

    def test_fulldup

        o0 = MyClass.new("cow")

        o1 = OpenWFE.fulldup(o0)

        assert_not_equal o0.object_id, o1.object_id
        assert_equal o0.name, o1.name
    end

    def test_yaml

        require 'yaml'

        o0 = MyClass.new("pig")
        o1 = YAML.load(o0.to_yaml)

        assert_not_equal o0.object_id, o1.object_id
        assert_equal o0.name, o1.name
    end

end
