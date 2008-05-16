class SearchbarSweeper < ActionController::Caching::Sweeper
  observe Project, Place, Partner, Cause

  def after_save(record)
    expire_fragment('searchbar')
  end
end