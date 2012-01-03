class ProfileController < ApplicationController
  include ProfileHelper
  
  def change
    self.panel_profile = params[:type]
    redirect_to root_url
  end

end
