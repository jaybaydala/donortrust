require 'test/unit'
require 'gift_mailer'
#require File.dirname(__FILE__) + '/test/test_helper'
 

class GiftMailSchedulerTest < Test::Unit::TestCase
  # TODO: fixture
  #fixtures :gifts

  def setup
    @reference_value = 0
    @emailer = GiftEmailer.new
  end

  def teardown
    @emailer.stop
    @emailer.scheduler = nil
  end

  def test_find_records
    count = @emailer.find_records(Time.now).length
    #TODO:fixtures
    #assert(count>0, 'Assertion was false.')
  end

  def test_start_scheduler
    @emailer.start
    assert_not_nil @emailer.scheduler
    #p @scheduler.methods
  end

  def small_task
    @reference_value = @reference_value+1
    p 'ran task: %s' % [@reference_value]
  end

  def test_run_once
    num_sent = @emailer.run_once
    #TODO: fixtures, specify how many will be sent
    assert_not_nil num_sent
  end

  def test_is_running
    assert @emailer.is_running==false
    @emailer.start
    assert @emailer.is_running
    @emailer.stop
  end
  def test_started_on
    @emailer.start
    assert @emailer.started_on<=Time.now
  end

end

require 'test/unit/ui/console/testrunner'
Test::Unit::UI::Console::TestRunner.run(GiftMailSchedulerTest)
