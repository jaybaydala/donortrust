module Dt::WishlistsHelper
  def options_for_wishlist_select
    watchlists = []
    #account = ['My Watchlist', 'personal']
    menberships = Membership.find_all_by_user_id(current_user.id, :conditions => ['membership_type >= ?', Membership.admin])
    if menberships.size > 0
      watchlists = menberships.collect do |menbership|
        ["Group: #{menbership.group.name}", "group-#{menbership.group.id}"]
      end
    end
    #watchlists = watchlists.unshift(account)
    options_for_select watchlists
  end
end
