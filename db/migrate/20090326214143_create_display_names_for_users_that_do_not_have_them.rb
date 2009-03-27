class CreateDisplayNamesForUsersThatDoNotHaveThem < ActiveRecord::Migration
  def self.up
    # There are some users in the database that do not have a first_name, last_name or display_name. Hack these.
    set_display_name_for_user_853('john005')
    set_display_name_for_user_909('gkisil')

    # Now find all users with a blank display_name and create one for them
    users = User.find(:all, :conditions => ['display_name = ""'])
    users.each do |user|
      set_display_name_for_user(user, "#{user.first_name} #{user.last_name[0,1]}.")   
    end

  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the altered data"
  end

  private
  def self.set_display_name_for_user_853(new_display_name)
    user = User.find_by_id(853)
    set_display_name_for_user(user, new_display_name)
  end

  private
  def self.set_display_name_for_user_909(new_display_name)
    user = User.find_by_id(909)
    set_display_name_for_user(user, new_display_name)
  end

  private
  def self.set_display_name_for_user(user, new_display_name)
    user.display_name = new_display_name
    user.save
  end

end
