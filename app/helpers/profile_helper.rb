module ProfileHelper
  def panel_profile
    session[:panel_profile] || :user
  end
end
