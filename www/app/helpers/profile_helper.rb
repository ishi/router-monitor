module ProfileHelper
  def panel_profile
    session[:panel_profile] ||= :user
  end
  
  def panel_profile=(profile)
    session[:panel_profile] = profile.to_sym unless profile.empty?
  end
  
  def is_profile?(profile)
    profile == panel_profile
  end
end
