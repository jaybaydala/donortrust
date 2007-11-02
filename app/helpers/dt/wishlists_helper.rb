module Dt::WishlistsHelper
  def options_for_wishlist_select
    watchlists = []
    #account = ['My Watchlist', 'personal']
    memberships = Membership.find_all_by_user_id(current_user.id, :conditions => ['membership_type >= ?', Membership.admin])
    if memberships.size > 0
      watchlists = memberships.collect do |membership|
        [membership.group.name, membership.group.id]
      end
    end
    options_for_select watchlists
  end
end
