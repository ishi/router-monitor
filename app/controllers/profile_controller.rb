class ProfileController < ApplicationController
  def change
    session[:panel_profile] = params[:type]
    redirect_to root_url
  end

end
