module Iend::UsersHelper
  def preferred_sector_options
    Sector.all.map{|s| ["#{image_tag('icons/sector-'+s.name.parameterize+'.png', :alt => '')}<br>#{s.name}".html_safe, s.id] }
  end
end
