
#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Sun Oct 29 16:18:25 JST 2006
#

require 'pp'
require 'test/unit'

require 'openwfe/util/scheduler'


#
# testing the Scheduler's CronLine system
#
class CronLineTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    def do_cltest (line, array)
        cl = OpenWFE::CronLine.new(line)

        unless cl.to_array == array
            puts
            pp cl.to_array
            puts "   should be"
            pp array
        end

        assert \
            cl.to_array == array
    end

    def test_cron_line_0
        do_cltest "* * * * *", [ nil, nil, nil, nil, nil ]
        do_cltest "10-12 * * * *", [ [10, 11, 12], nil, nil, nil, nil ]
        do_cltest "* * * * sun,mon", [ nil, nil, nil, nil, [7, 1] ]
        do_cltest "* * * * mon-wed", [ nil, nil, nil, nil, [1, 2, 3] ]

        #do_cltest "* * * * sun,mon-tue", [ nil, nil, nil, nil, [7, 1, 2] ]
        #do_cltest "* * * * 7-1", [ nil, nil, nil, nil, [7, 1, 2] ]
    end

end
