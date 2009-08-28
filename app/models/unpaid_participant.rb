class UnpaidParticipant < ActiveRecord::Base
  image_column  :picture,
                :versions => { :thumb => "100x100", :full => "200x200"  },
                :filename => proc{|inst, orig, ext| "participant_#{inst.id}.#{ext}"},
                :store_dir => "uploaded_pictures/participant_pictures"

  validates_size_of :picture, :maximum => 500000, :message => "might be too big, must be smaller than 500kB!", :allow_nil => true
  
end