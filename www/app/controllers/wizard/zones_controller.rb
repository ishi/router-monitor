# encoding: utf-8
class Wizard::ZonesController < ApplicationController
  def index
    @zones = Zone.all
  end

  def update
    @zone = Zone.new(params[:zone])
    @zone.save
  end

  def delete
    @zone = Zone.new(params[:zone])
    respond_to do |format|
      if @zone.delete
        format.js
      else
        format.js { render :inline => 'alert("Błąd podczas usuwania konfiguracji strefy")'}
      end
    end
  end
end
