
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'test/unit'
require 'openwfe/util/dollar'

#
# testing the 'dollar notation'
#

class DollarTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    def test_one
        dict = {}
        dict['renard'] = 'goupil'
        dict['cane'] = 'oie'
        dict['oie blanche'] = 'poule'

        dotest("le petit renard", dict, "le petit renard")
        dotest("le petit {renard}", dict, "le petit {renard}")
        dotest("le petit ${renard}", dict, "le petit goupil")
        dotest("le petit ${renard} noir", dict, "le petit goupil noir")

        dotest("la grande ${${cane} blanche}", dict, "la grande poule")

        dotest("le ${renard} et la ${cane}", dict, "le goupil et la oie")
            #
            # excuse my french...

        dotest("le \\${renard} encore", dict, "le \\${renard} encore")

        dotest("", dict, "")

        dotest("""
""", dict, """
""")
        dotest(""" 
""", dict, """ 
""")
    end

    def test_two
        dict = {}
        dict['x'] = 'y'
        dotest("${x}", dict, "y")
        dotest("\\${x}", dict, "\\${x}")
    end

    def test_three
        dict = {}
        dict['A'] = 'a'
        dict['B'] = 'b'
        dict['ab'] = 'ok'
        dotest("${${A}${B}}", dict, "ok")
    end

    def dotest (text, dict, target)
        result = OpenWFE::dsub(text, dict)
        #puts "..>#{text}<"
        #puts "...->"
        #puts "..>#{result}<"
        #puts
        assert \
            result == target,
            ">#{result}< != >#{target}<"
    end
end
