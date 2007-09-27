
#
# Testing OpenWFEru
#
# John Mettraux at openwfe.org
#
# Tue Jan  2 13:14:37 JST 2007
#

require 'openwfe/workitem'
require 'openwfe/engine/engine'
require 'openwfe/expressions/raw_prog'
require 'openwfe/participants/participants'
require 'openwfe/participants/enoparticipants'
require 'flowtestbase'

include OpenWFE


class EnoTest < Test::Unit::TestCase

    #def setup
    #end

    #def teardown
    #end

    #
    # Test 0
    #

    class TestDefinition0 < ProcessDefinition
        email_notification_participant
    end

    def test_eno

        puts "  TARGET is #{ENV['TARGET']}"

        engine = Engine.new

        eno = MailParticipant.new(
            :smtp_server => "mail.google.com"
            :from_address => "eno@outoftheblue.co.jp"
        ) do

            s = ""
            s << "Subject: test 0\n\n"

            s << "konnichiwa. #{Time.now.to_s}\n\n"

            s
        end

        engine.register_participant("email_notification_participant", eno)

        li = LaunchItem.new(TestDefinition0)

        li.email_target = ENV["TARGET"]

        fei = engine.launch(li)

        engine.wait_for fei
    end
end

