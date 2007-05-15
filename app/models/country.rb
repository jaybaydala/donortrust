class Country < ActiveRecord::Base

belongs_to :continent

def to_label

"#{country_name}"
end

end
