require File.dirname(__FILE__) + '/../test_helper'

class ErrorMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    @controller = Dt::ProjectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end
  
  def test_mail_does_not_throw_an_error
    get :index
    begin
      raises CrazyException
    rescue => exception
      ErrorMailer.create_snapshot(
        exception, 
        @controller.send(:clean_backtrace, exception),
        @controller.session.instance_variable_get("@data"), 
        @controller.params, 
        @request.env)
    end
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/error_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
