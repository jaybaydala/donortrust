class CopyImagesToS3ViaPaperclip < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      say_with_time "Updating User Images..." do
        User.picture_file_name_not_null.each do |r|
          path = File.join("uploaded_pictures", "pictures", r.id.to_s, "original")
          copy_picture(r, path, r.picture_file_name)
        end
        # path = File.join(Rails.root, "public", "system", "uploaded_pictures", "pictures")
        # User.picture_file_name_not_null.each do |user|
        #   filepath = File.join(path, u.id.to_s, "original", u.picture_file_name)
        #   if user.picture? && File.exists?(filepath)
        #     say "- #{user.class}##{user.id} uploading"
        #     user.image = user.picture
        #   else
        #     say "- #{user.class}##{user.id}" if !user.picture?
        #     say "- #{user.class}##{user.id} ALREADY uploaded" if user.image?
        #   end
        # end
      end
      say_with_time "Updating Campaign Images..." do
        Campaign.picture_not_null.each{|r| copy_picture(r, "uploaded_pictures/campaign_pictures", r.picture.filename) }
      end
      say_with_time "Updating Team Images..." do
        Team.picture_not_null.each{|r| copy_picture(r, "uploaded_pictures/team_pictures", r.picture.filename) }
      end
      say_with_time "Updating Participant Images..." do
        Participant.picture_not_null.each{|r| copy_picture(r, "uploaded_pictures/participant_pictures", r.picture.filename) }
      end
      say_with_time "Updating Unpaid Participant Images..." do
        UnpaidParticipant.picture_not_null.each{|r| copy_picture(r, "uploaded_pictures/participant_pictures", r.picture.filename) }
      end
    end
  end

  def self.down
  end
  
  def self.copy_picture(record, path, filename)
    file_path = File.join(Rails.root, "public", "system", path, filename) if record.picture?
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
