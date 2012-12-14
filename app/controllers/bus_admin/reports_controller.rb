require 'fastercsv'

class BusAdmin::ReportsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'

  
  def process_report
    
    start_date_params = params[:report].select{|k,v| k =~ /start_date/}.sort_by{|d| d[0] }.collect{|d| d[1].to_i }
    @start_date = DateTime.civil(*start_date_params)

    end_date_params = params[:report].select{|k,v| k =~ /end_date/}.sort_by{|d| d[0] }.collect{|d| d[1].to_i }
    @end_date = DateTime.civil(*end_date_params)

    # Check for invalid dates just in case
    if @start_date.blank? || @end_date.blank?
      flash[:error] = "One of the dates was not valid: #{@start_date.inspect} - #{@end_date.inspect}."
      redirect_to('/bus_admin/reports') and return
    end
    if @end_date < @start_date
      flash[:error] = "End date must be before start date."
      redirect_to('/bus_admin/reports') and return
    end

    report = Report.new(params[:report])
    report_type = params[:report][:report_type] ||= "gift_report";

    case
    when report_type == "gift_average_report":
      sqlString = "SELECT DATE(created_at) As Date, SUM(amount) As Total, Round(avg(amount),2) as Average, COUNT(*) as Transactions 
                   FROM gifts 
                   WHERE DATE(created_at) >= '" + midnight_string_on(@start_date) + "' 
                   AND DATE(created_at) < '" + midnight_string_on_the_day_after(@end_date) + "'
                   GROUP BY DATE(created_at)"
       @results = Gift.find_by_sql(sqlString)
       export(@results, "Gift")


    when report_type == "expired_gifts_report":
      @gifts = Gift.all(:conditions => ["sent_at < ? AND picked_up_at IS NULL AND created_at BETWEEN ? AND ?", 30.days.ago, @start_date.beginning_of_day, @end_date.end_of_day])
      send_csv_data(render_to_string(:action => "expired_gifts", :layout => false), "expired_gifts_report")

    when report_type == "deposit_average_report":
      sqlString = "SELECT DATE(created_at) As Date, SUM(amount) As Total, Round(avg(amount),2) as Average, COUNT(*) as Transactions 
                   FROM deposits 
                   WHERE DATE(created_at) >= '" + midnight_string_on(@start_date) + "' 
                   AND DATE(created_at) < '" + midnight_string_on_the_day_after(@end_date) + "'
                   GROUP BY DATE(created_at)"
      @results = Deposit.find_by_sql(sqlString)
      export(@results, "Deposit")

    when report_type == "investment_average_report":
      sqlString = "SELECT DATE(created_at) As Date, SUM(amount) As Total, Round(avg(amount),2) as Average, COUNT(*) as Transactions 
                   FROM investments 
                   WHERE DATE(created_at) >= '" + midnight_string_on(@start_date) + "' 
                   AND DATE(created_at) < '" + midnight_string_on_the_day_after(@end_date) + "'
                   GROUP BY DATE(created_at)"
      @results = Investment.find_by_sql(sqlString)
      export(@results, "Investment")

    when report_type == "pledge_average_report":
      sqlString = "SELECT DATE(created_at) As Date, SUM(amount) As Total, Round(avg(amount),2) as Average, COUNT(*) as Transactions 
                   FROM pledges 
                   WHERE DATE(created_at) >= '" + midnight_string_on(@start_date) + "' 
                   AND DATE(created_at) < '" + midnight_string_on_the_day_after(@end_date) + "'
                   GROUP BY DATE(created_at)"
      @results = Pledge.find_by_sql(sqlString)
      export(@results, "Pledge")

    when report_type == "project_breakdown":
      sqlString = "SELECT PA.name AS partner_name, P.id, P.name, sum(I.amount) AS total_investment, P.total_cost 
                   FROM projects AS P INNER JOIN investments AS I INNER JOIN partners as PA
                   ON I.project_id = P.id
                   AND P.partner_id = PA.id
                   WHERE I.created_at >= '" + midnight_string_on(@start_date) + "'
                   AND I.created_at < '" + midnight_string_on_the_day_after(@end_date) + "'
                   GROUP BY P.id
                   ORDER BY PA.name ASC"
      @results = Project.find_by_sql(sqlString)
 
      csv_string = FasterCSV.generate do |csv|
        csv << ["Project breakdown report for dates between " + @start_date.to_s + " and " + @end_date.to_s]
        csv << ["Partner", "Project ID", "Project",  "Total Investments",  "Total Cost" ]
        @results.each do |result|
          csv << [result.partner_name, result.id, result.name, result.total_investment, result.total_cost]
        end
      end

      send_csv_data(csv_string)

    when report_type == "order_report"
      @orders = Order.all(
        :conditions => ["complete=? AND created_at BETWEEN ? AND ?", true, @start_date.beginning_of_day, @end_date.end_of_day],
        :include => [:user, :deposits, :gifts, {:investments => {:project => :partner}}, :pledges, :tips]
      )
      send_csv_data(render_to_string(:action => "orders", :layout => false), "order_report")
    when report_type == "allocations_order_report"
      @orders = User.find_by_login("info@christmasfuture.org").orders.all(
        :conditions => ["complete=? AND created_at BETWEEN ? AND ?", true, @start_date.beginning_of_day, @end_date.end_of_day],
        :include => [:user, :deposits, :gifts, {:investments => {:project => :partner}}, :pledges]
      )
      send_csv_data(render_to_string(:action => "orders", :layout => false), "order_report")
    when report_type == "allocations_deposit_report"
      @deposits = User.find_by_login("info@christmasfuture.org").deposits.all(
        :conditions => ["created_at BETWEEN ? AND ?", @start_date.beginning_of_day, @end_date.end_of_day],
        :include => [:user, :gift, :order]
      )
      send_csv_data(render_to_string(:action => "orders", :layout => false), "allocations_deposit_report")
    when report_type == "transaction_report"
      @orders = Order.all(
        :conditions => ["complete=? AND created_at BETWEEN ? AND ?", true, @start_date.beginning_of_day, @end_date.end_of_day],
        :include => [:user, :deposits, :gifts, {:investments => {:project => :partner}}, :pledges, :tips]
      )
      # render :action => "transactions", :layout => false
      send_csv_data(render_to_string(:action => "transactions", :layout => false), "transaction_report")
    when report_type == "pledge_report"
      @pledges = Pledge.all(
        :conditions => ["created_at BETWEEN ? AND ?", @start_date.beginning_of_day, @end_date.end_of_day],
        :include => [:team, :campaign]
      )
      send_csv_data(render_to_string(:action => "pledges", :layout => false), "pledge_report")
    else
      # TODO: What should happen here? Raise an exception?
    end

  end

  def export(results, report_title)    
    
    csv_string = FasterCSV.generate do |csv|
      csv << [report_title + " report for dates between " + @start_date.to_s(:short) + " and " + @end_date.tomorrow.to_s(:short)] if report_title
      csv << ["Date", "No. of Transactions", "Daily Average",  "Daily Total" ]
      @results.each do |result|
        csv << [result.Date, result.Transactions, result.Average,  result.Total]
      end
    end

    # render :text => csv_string, :content_type => "text/plain" and return
    send_csv_data(csv_string)
  end

  private
  def send_csv_data(csv_string, filename = "project")
    headers['Cache-Control'] = 'private'
    send_data csv_string,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{filename}.csv"
  end
   
  private 
  def get_date(dateType)
    year = params[:report][dateType + "_date(1i)"] if params[:report][dateType + "_date(1i)"] != ""
    month = params[:report][dateType + "_date(2i)"] if params[:report][dateType + "_date(2i)"] != ""
    day = params[:report][dateType + "_date(3i)"] if params[:report][dateType + "_date(3i)"] != ""
    Date.new(year.to_i, month.to_i, day.to_i)
  end      

  private
  def midnight_string_on(date)
    return nil unless date
    #date.to_s(:db) + " 00:00:00"
    date.beginning_of_day.to_s(:db)
  end

  private
  def midnight_string_on_the_day_after(date)
    return nil unless date
    # date.advance(:days => 1).to_s(:db) + " 00:00:00"
    (date.beginning_of_day.tomorrow).to_s(:db)
  end

end
