
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#

require 'tempfile'

require 'test/unit'
require 'openwfe/util/safe'


class SafelyTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    #def test_safely_0
    #    assert_not_nil dotest("print ''", 4)
    #    assert_not_nil dotest2("print ''", 4)
    #    assert_nil dotest("print ''", 2)
    #    assert_nil dotest2("print ''", 2)
    #end

    def test_safely_1

        if OpenWFE::on_jruby?
            puts
            puts "skipping safe tests as JRuby doesn't support $SAFE levels..."
            return
        end

        assert_not_nil dotest3(STDOUT, "self.print ''", 4)
        assert_nil dotest3(STDOUT, "self.print ''", 2)

        assert_not_nil dotest3(nil, "print ''", 4)
        assert_nil dotest3(nil, "print ''", 2)
    end

    protected

        #def dotest (code, level)
        #    tf = Tempfile.new "safely_test_temp.rb"
        #    tf.puts code
        #    tf.close
        #    e = nil
        #    begin
        #        OpenWFE::load_safely(tf.path, level)
        #    rescue Exception => e
        #    end
        #    File.delete(tf.path)
        #    e
        #end

        #def dotest2 (code, level)
        #    begin
        #        OpenWFE::load_eval_safely(code, level)
        #    rescue Exception => e
        #        return e
        #    end
        #    nil
        #end

        def dotest3 (instance, code, level)

            begin
                if instance
                    OpenWFE::instance_eval_safely(instance, code, level)
                else
                    OpenWFE::eval_safely(code, level)
                end
            rescue Exception => e
                return e
            end

            nil
        end

end

