module Cucumber
  module Rails
      module SelectDatesAndTimes

        def select_date(field_prefix, time)
          find(:xpath, ".//select[@id='#{field_prefix}_1i']").select(time.year.to_s)
          find(:xpath, ".//select[@id='#{field_prefix}_2i']").select(Date::MONTHNAMES[time.month])
          find(:xpath, ".//select[@id='#{field_prefix}_3i']").select(time.day.to_s)
        end

        def select_month(field_prefix, time)
          find(:xpath, ".//select[@id='#{field_prefix}_2i']").select(Date::MONTHNAMES[time.month])
        end

        def select_time(field_prefix, time)
          find(:xpath, ".//select[@id='#{field_prefix}_4i']").select(time.hour.to_s.rjust(2, '0'))
          find(:xpath, ".//select[@id='#{field_prefix}_5i']").select('00')
        end

        def select_datetime(field_prefix, time)
          select_date(field_prefix, time)
          select_time(field_prefix, time)
        end

      end
    end
end

World(::Cucumber::Rails::SelectDatesAndTimes)