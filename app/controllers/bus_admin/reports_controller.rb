require 'csv'
require 'fastercsv'

class BusAdmin::ReportsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :check_authorization
  #access_control :DEFAULT => 'cf_admin'
  
  def process_report
    
    @endDate= get_date(true)
    @startDate= get_date(false)  
    if @startDate == "--"
      @startDate = (Time.now.year).to_s + "-" + (Time.now.month).to_s + "-" + (Time.now.day).to_s
    end    

    selected_report = params[:report][:gift].to_s;

    case
    when selected_report == "gift_report":
      sqlString = "SELECT DATE(created_at) As Date, SUM(amount) As Total, Round(avg(amount),2) as Average, COUNT(*) as Transactions FROM gifts WHERE DATE(created_at) >= '" + @startDate.to_s + "' AND DATE(created_at) <= '" + @endDate.to_s + "' GROUP BY DATE(created_at)"
       @results = Gift.find_by_sql(sqlString)
       export(@results)

    when selected_report == "deposit_report":
      sqlString = "SELECT DATE(created_at) As Date, SUM(amount) As Total, Round(avg(amount),2) as Average, COUNT(*) as Transactions FROM deposits WHERE DATE(created_at) >= '" + @startDate.to_s + "' AND DATE(created_at) <= '" + @endDate.to_s + "' GROUP BY DATE(created_at)"
       @results = Deposit.find_by_sql(sqlString)
        export(@results)

    when selected_report == "investment_report":
      sqlString = "SELECT DATE(created_at) As Date, SUM(amount) As Total, Round(avg(amount),2) as Average, COUNT(*) as Transactions FROM investments WHERE DATE(created_at) >= '" + @startDate.to_s + "' AND DATE(created_at) <= '" + @endDate.to_s + "' GROUP BY DATE(created_at)"
       @results = Investment.find_by_sql(sqlString)
        export(@results)

    when selected_report == "pledge_report":
      sqlString = "SELECT DATE(created_at) As Date, SUM(amount) As Total, Round(avg(amount),2) as Average, COUNT(*) as Transactions FROM pledges WHERE DATE(created_at) >= '" + @startDate.to_s + "' AND DATE(created_at) <= '" + @endDate.to_s + "' GROUP BY DATE(created_at)"
       @results = Pledge.find_by_sql(sqlString)
        export(@results)

    when selected_report == "project_breakdown":

      sqlString = "SELECT PA.name AS partner_name, P.id, P.name, sum(I.amount) AS total_investment, P.total_cost 
                   FROM projects AS P INNER JOIN investments AS I INNER JOIN partners as PA
		   ON I.project_id = P.id
		   AND P.partner_id = PA.id
		   WHERE I.created_at >= '" + @startDate.to_s + "'
		   AND I.created_at <= '" + @endDate.to_s + "'
		   GROUP BY P.id
		   ORDER BY PA.name ASC"

      @results = Project.find_by_sql(sqlString)
 
      csv_string = FasterCSV.generate do |csv|
        csv << ["Partner", "Project ID", "Project",  "Total Investments",  "Total Cost" ]
        @results.each do |result|
          csv << [result.partner_name, result.id, result.name, result.total_investment, result.total_cost]
        end
      end

      send_csv_data(csv_string)

    else
      # TODO: What should happen here? Raise an exception?
    end

  end
  
  def get_date(isEndDate)
    send_at_vals = Array.new
    (1..3).each do |x|
      if isEndDate == true
        send_at_vals << params[:report]["end_date(#{x}i)"] if params[:report]["end_date(#{x}i)"] != ""
      else
        send_at_vals << params[:report]["start_date(#{x}i)"] if params[:report]["start_date(#{x}i)"] != ""
      end
    end
    send_at = ((send_at_vals[0]).to_s + '-' + (send_at_vals[1]).to_s + '-' + (send_at_vals[2]).to_s).to_s
  end      

  def export(results)    

    csv_string = FasterCSV.generate do |csv|
      csv << ["Date", "No. of Transactions", "Daily Average",  "Daily Total" ]
      @results.each do |result|
        csv << [result.Date, result.Transactions, result.Average,  result.Total]
      end
    end

    send_csv_data(csv_string)

  end

  private
  def send_csv_data(csv_string)
    headers['Cache-Control'] = 'private'
    send_data csv_string,
       
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=project.csv"
  end
  
end
