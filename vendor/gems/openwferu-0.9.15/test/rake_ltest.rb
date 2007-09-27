#
# Testing OpenWFE
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

#require 'test/unit'

#
# the tests that take lots of time...
#
require 'ft_5_time'
require 'scheduler_test'
require 'cron_test'

require 'restart_tests'

require 'ft_20_cron'
require 'ft_21_cron'
require 'ft_67_schedlaunch'

require 'ft_51_stack'

#require 'ft_30_socketlistener'
    #
    # shaky test...

require 'extras/csv_test'
    #
    # this test taps the google docs servers, its duration is very
    # variable, so it's been put here, with lengthy tests

#
# the quick tests
#
#require 'rake_qtest'

