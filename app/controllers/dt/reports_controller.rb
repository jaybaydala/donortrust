class Dt::ReportsController < ApplicationController
  helper "dt/report"
  def index
  end 

  def report_by_countries
    @from = params[:time_from]
    @to = params[:time_to]
    @interval = params[:time_interval]

    @summary=DtReport.by_countries({:time_from => [@from,@to]})
    @countries = @summary.map { |h| h["country"] }
    @reports=[]
    each_intervals(@from,@to,@interval) do |from,to|
      @reports << [from,to,DtReport.by_countries({:time_from => [from,to]})]
    end
    
    render :partial => "report_by_countries"
  end

  def report_by_partners
    @from = params[:time_from]
    @to = params[:time_to]
    @interval = params[:time_interval]

    @summary=DtReport.by_partners({:time_from => [@from,@to]})
    @countries = @summary.map { |h| h["partner"] }
    @reports=[]
    each_intervals(@from,@to,@interval) do |from,to|
      @reports << [from,to,DtReport.by_partners({:time_from => [from,to]})]
    end 
    render :partial => "report_by_partners" 
  end

  def report_by_causes
    @from = params[:time_from]
    @to = params[:time_to]
    @interval = params[:time_interval]

    @summary=DtReport.by_causes({:time_from => [@from,@to]})
    @countries = @summary.map { |h| h["causes"] }
    @reports=[]
    each_intervals(@from,@to,@interval) do |from,to|
      @reports << [from,to,DtReport.by_causes({:time_from => [from,to]})]
    end 
    render :partial => "report_by_causes" 
  end

  def show_report_form
    render :partial => "form_#{params[:report]}"
  end

  private

  def each_intervals(from,to,interval)
    from = Time.parse from if !from.is_a? Time
    to = Time.parse to if !to.is_a? Time

    case interval
    when "Monthly"
      interval = 1.month
    when "Quarterly"
      interval = 4.month
    when "Annually"
      interval = 12.month
    else
      raise "Unknown time interval: #{interval}"
    end

    t=from
    while t < to
      yield t, t+interval
      t += interval
    end
  end
end
