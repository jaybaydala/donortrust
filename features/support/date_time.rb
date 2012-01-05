module Cucumber
  module Rails
    module Capybara
      # This module defines methods for selecting dates and times
      module SelectDatesAndTimes
        # Select a Rails date with label +field+
        def select_date(field_prefix, time)

          find(:xpath, ".//select[@id='#{field_prefix}_1i']").select(time.year.to_s)
          find(:xpath, ".//select[@id='#{field_prefix}_2i']").select(Date::MONTHNAMES[time.month])
          find(:xpath, ".//select[@id='#{field_prefix}_3i']").select(time.day.to_s)
        end
      
        # Select a Rails time with label +field+
        def select_time(field_prefix, time)

          find(:xpath, ".//select[@id='#{field_prefix}_4i']").select(time.hour.to_s.rjust(2, '0'))
          find(:xpath, ".//select[@id='#{field_prefix}_5i']").select('00')
        end
      
        # Select a Rails date and time with label +field+
        def select_datetime(field_prefix, time)
          select_date(field_prefix, time)
          select_time(field_prefix, time)
        end

      end
    end
  end
end

World(::Cucumber::Rails::Capybara::SelectDatesAndTimes)