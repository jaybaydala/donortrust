module Dt::WishlistsHelper
  def options_for_wishlist_select
    watchlists = []
    #account = ['My Watchlist', 'personal']
    @memberships = Membership.find_all_by_user_id(current_user.id, :conditions => ['membership_type >= ?', Membership.admin], :include => :group)
    if @memberships.size > 0
      watchlists = @memberships.collect do |membership|
        next unless membership.group_id? && membership.group
        [membership.group.name, membership.group.id]
      end
      watchlists.delete_if {|x| x.nil? }
      watchlists.unshift(['Choose a group...', '']) if watchlists.size > 0
    end
    options_for_select watchlists
  end
end
