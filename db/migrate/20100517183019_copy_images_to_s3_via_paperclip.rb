class CopyImagesToS3ViaPaperclip < ActiveRecord::Migration
  def self.up
    
    say_with_time "Updating User Images..." do
      User.all.each{|r| copy_picture(r) }
    end
    say_with_time "Updating Campaign Images..." do
      Campaign.all.each{|r| copy_picture(r) }
    end
    say_with_time "Updating Team Images..." do
      Team.all.each{|r| copy_picture(r) }
    end
    say_with_time "Updating Participant Images..." do
      Participant.all.each{|r| copy_picture(r) }
    end
    say_with_time "Updating Unpaid Participant Images..." do
      UnpaidParticipant.all.each{|r| copy_picture(r) }
    end
  end

  def self.down
  end
  
  def self.copy_picture(record)
    if record.picture? && File.exists?(record.picture.path)
      say "- #{record.class}##{record.id} uploading"
      record.image = File.open(record.picture.path, "r")
      record.save
    end
  end
end
