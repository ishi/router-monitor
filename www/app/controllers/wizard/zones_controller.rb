class Wizard::ZonesController < ApplicationController
  def index
    @zones = Zone.all || [Zone.new]
  end

  def update
    @zones = []
    params[:zone].each do |k, z|
      zone = Zone.new(z)
      zone.valid?
      @zones << zone
    end

    render :index
  end
end
