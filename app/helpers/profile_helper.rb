module ProfileHelper
  def panel_profile
    session[:panel_profile] || :user
  end
  
  def is_profile?(profile)
    profile == session[:panel_profile]
  end
end
