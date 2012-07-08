class Wizard::ZonesController < ApplicationController
  def index
    @zones = Zone.all
  end

  def update
    @zones = []
    for lp, z in params[:zone] do
      @zones << Zone.new(z)
    end

    render :index
  end
end
