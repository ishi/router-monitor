module ProfileHelper
  def panel_profile
    case request.path
    when /^\/wizard/
      :wizard
    when /^\/panel/
      :panel
    when /^\/editor/
      :editor
    else
      session[:panel_profile] ||= :user
    end
  end
  
  def panel_profile=(profile)
    session[:panel_profile] = profile.to_sym unless profile.empty?
  end
  
  def is_profile?(profile)
    profile == panel_profile
  end
end
