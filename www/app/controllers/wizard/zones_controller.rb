class Wizard::ZonesController < ApplicationController
  def index
    @zones = Zone.all
  end

  def update
    @zone = Zone.new(params[:zone])
    @zone.save
  end
end
