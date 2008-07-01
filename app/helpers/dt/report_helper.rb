require 'google_chart'

module Dt::ReportHelper
  def format_interval(from,to)
    from = Time.parse from if !from.is_a? Time
    to = Time.parse to if !to.is_a? Time
    "<h2>#{from.strftime '%b %d, %Y'} -- #{to.strftime '%b %d, %Y'}</h2>"
  end

  def pie_chart(tuples,opts={ })
    opts.reverse_merge! :size => '500x250', :is_3d => false
    title=opts[:label]
    url = nil
    GoogleChart::PieChart.new(opts[:size], title, opts[:is_3d]) do |pc|
      #pc.show_labels = false unless title
      for k,v in tuples
        pc.data k,v
      end
      url = pc.to_url
    end
    image_tag url
  end

  def line_chart(tuples,opts={ })
    opts.reverse_merge! :size => '500x250'
    url=nil
    GoogleChart::LineChart.new(opts[:size], opts[:title], opts[:is_xy]) do |l|
      tuples.each do |tuple|
        label, data, color = tuple
        l.data label,data, color
        l.axis :y, opts[:y] if opts[:y]
        l.axis :x, opts[:x] if opts[:x]
        url = l.to_url
      end
    end
    image_tag url
  end
end
