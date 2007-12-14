class Dt::SearchGroupsController < DtApplicationController
  helper_method :current_member
  
  def show
    search_conditions = ''
    Group.searchable_columns.each do |k|
      search_conditions += " OR " unless search_conditions.empty?
      if k.match(/\./)
        search_conditions += "#{k} LIKE ?"
      else
        search_conditions += "#{Group.table_name}.#{k} LIKE ?"
      end
    end
    unless search_conditions.empty? && params[:q] && !params[:q].empty?
      conditions = ["private=? AND (#{search_conditions})", false]
      Group.searchable_columns.each do |k|
        conditions << "%#{params[:q]}%"
      end
    else
      conditions = ["private=?", false]
    end
    @groups = Group.paginate(:page => params[:page], :per_page => 5, :conditions => conditions, :include => :group_type)
  end

  protected
  def current_member(group = nil, user = current_user)
    group ||= Group.find(params[:id])
    @current_member ||= group.memberships.find_by_user_id(user) if user
  end

end
