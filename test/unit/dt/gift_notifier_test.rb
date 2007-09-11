require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/gift_test_helper'

context "GiftNotifier Test" do
  include GiftTestHelper
  FIXTURES_PATH = File.dirname(__FILE__) + '/../../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  setup do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
    @gift = create_gift
  end


  def test_gift
    @expected.subject = 'You have received a ChristmasFuture Gift from ' + ( @gift.name != nil ? @gift.name : @gift.email )
    @expected.body    = read_fixture('gift')
    @expected.date    = Time.now


    email = GiftNotifier.create_gift(@gift).encoded
    email.should =~ @gift.to_name
    email.should =~ @gift.to_email
    email.should =~ @gift.name
    email.should =~ @gift.email
  end

  def xtest_open
    @expected.subject = 'GiftNotifier#open'
    @expected.body    = read_fixture('open')
    @expected.date    = Time.now

    assert_equal @expected.encoded, GiftNotifier.create_open(@gift).encoded
  end

  def xtest_remind
    @expected.subject = 'GiftNotifier#remind'
    @expected.body    = read_fixture('remind')
    @expected.date    = Time.now

    assert_equal @expected.encoded, GiftNotifier.create_remind(@gift).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/gift_notifier/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
    
    def get_binding
      binding
    end
end
