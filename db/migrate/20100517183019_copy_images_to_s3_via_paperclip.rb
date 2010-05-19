class CopyImagesToS3ViaPaperclip < ActiveRecord::Migration
  def self.up
    
    say_with_time "Updating User Images..." do
      User.all.each do |user| 
        if user.picture? && !user.image?
          say "- #{user.class}##{user.id} uploading"
          user.image = user.picture
        else
          say "- #{user.class}##{user.id}" if !user.picture?
          say "- #{user.class}##{user.id} ALREADY uploaded" if user.image?
        end
      end
    end
    say_with_time "Updating Campaign Images..." do
      Campaign.all.each{|r| copy_picture(r, "uploaded_pictures/campaign_pictures") }
    end
    say_with_time "Updating Team Images..." do
      Team.all.each{|r| copy_picture(r, "uploaded_pictures/team_pictures") }
    end
    say_with_time "Updating Participant Images..." do
      Participant.all.each{|r| copy_picture(r, "uploaded_pictures/participant_pictures") }
    end
    say_with_time "Updating Unpaid Participant Images..." do
      UnpaidParticipant.all.each{|r| copy_picture(r, "uploaded_pictures/participant_pictures") }
    end
  end

  def self.down
  end
  
  def self.copy_picture(record, path)
    file_path = File.join(Rails.root, "public", "system", path, record.picture.filename) if record.picture?
    if record.picture? && File.exists?(file_path)# && !record.image?
      say "- #{record.class}##{record.id} uploading"
      record.image = File.open(file_path, "r")
      record.save
    else
      say "- #{record.class}##{record.id}" if !record.picture?
      say "- #{record.class}##{record.id} ALREADY uploaded" if record.image?
      say "- #{record.class}##{record.id} has NO PICTURE FILE" if record.picture? && !File.exists?(file_path)
    end
  end
end
