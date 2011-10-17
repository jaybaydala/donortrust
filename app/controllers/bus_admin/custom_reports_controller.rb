class BusAdmin::CustomReportsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  before_filter :load_valid_reports

    def index

    end

    protected
      def load_valid_reports
        @valid_reports = {
          :gift_card_tips => "Gift Card Tips",
          :active_subscribers => "Active Subscribers"
        }
      end

  end