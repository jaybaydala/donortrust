require 'csv'
require 'fastercsv'

class BusAdmin::ReportsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'
  
  def process_report
    
    @endDate= get_date("end")
    @startDate= get_date("start")  

    # We know by this point we have both a start and end date to work with 
    # because the UI doesn't allow blanks to be selected
    if @endDate < @startDate
      flash[:error] = "End date must be before start date."
      redirect_to('/bus_admin/reports')
    end

    selected_report = params[:report][:gift].to_s;

    case
    when selected_report == "gift_report":
      sqlString = "SELECT DATE(created_at) As Date, SUM(amount) As Total, Round(avg(amount),2) as Average, COUNT(*) as Transactions FROM gifts WHERE DATE(created_at) >= '" + @startDate.to_s(:db) + "' AND DATE(created_at) <= '" + @endDate.to_s(:db) + "' GROUP BY DATE(created_at)"
       @results = Gift.find_by_sql(sqlString)
       export(@results)

    when selected_report == "deposit_report":
      sqlString = "SELECT DATE(created_at) As Date, SUM(amount) As Total, Round(avg(amount),2) as Average, COUNT(*) as Transactions FROM deposits WHERE DATE(created_at) >= '" + @startDate.to_s(:db) + "' AND DATE(created_at) <= '" + @endDate.to_s(:db) + "' GROUP BY DATE(created_at)"
       @results = Deposit.find_by_sql(sqlString)
        export(@results)

    when selected_report == "investment_report":
      sqlString = "SELECT DATE(created_at) As Date, SUM(amount) As Total, Round(avg(amount),2) as Average, COUNT(*) as Transactions FROM investments WHERE DATE(created_at) >= '" + @startDate.to_s(:db) + "' AND DATE(created_at) <= '" + @endDate.to_s(:db) + "' GROUP BY DATE(created_at)"
       @results = Investment.find_by_sql(sqlString)
        export(@results)

    when selected_report == "pledge_report":
      sqlString = "SELECT DATE(created_at) As Date, SUM(amount) As Total, Round(avg(amount),2) as Average, COUNT(*) as Transactions FROM pledges WHERE DATE(created_at) >= '" + @startDate.to_s(:db) + "' AND DATE(created_at) <= '" + @endDate.to_s(:db) + "' GROUP BY DATE(created_at)"
       @results = Pledge.find_by_sql(sqlString)
        export(@results)

    when selected_report == "project_breakdown":

      sqlString = "SELECT PA.name AS partner_name, P.id, P.name, sum(I.amount) AS total_investment, P.total_cost 
                   FROM projects AS P INNER JOIN investments AS I INNER JOIN partners as PA
                   ON I.project_id = P.id
                   AND P.partner_id = PA.id
                   WHERE I.created_at >= '" + @startDate.to_s(:db) + "'
                   AND I.created_at <= '" + @endDate.to_s(:db) + "'
                   GROUP BY P.id
                   ORDER BY PA.name ASC"

      @results = Project.find_by_sql(sqlString)
 
      csv_string = FasterCSV.generate do |csv|
        csv << ["Project breakdown report for dates between " + @startDate.to_s + " and " + @endDate.to_s]
        csv << ["Partner", "Project ID", "Project",  "Total Investments",  "Total Cost" ]
        @results.each do |result|
          csv << [result.partner_name, result.id, result.name, result.total_investment, result.total_cost]
        end
      end

      send_csv_data(csv_string)

    else
      # TODO: What should happen here? Raise an 
    end

  end

  def export(results)    
    csv_string = FasterCSV.generate do |csv|
      csv << ["Date", "No. of Transactions", "Daily Average",  "Daily Total" ]
      @results.each do |result|
        csv << [result.Date, result.Transactions, result.Average,  result.Total]
      end
    end
    headers['Cache-Control'] = 'private'
    send_data csv_string,
       
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=project.csv"
  end
   
  private 
  def get_date(dateType)
    year = params[:report][dateType + "_date(1i)"] if params[:report][dateType + "_date(1i)"] != ""
    month = params[:report][dateType + "_date(2i)"] if params[:report][dateType + "_date(2i)"] != ""
    day = params[:report][dateType + "_date(3i)"] if params[:report][dateType + "_date(3i)"] != ""
    Date.new(year.to_i, month.to_i, day.to_i)
  end      

end
