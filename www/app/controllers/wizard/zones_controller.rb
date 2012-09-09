# encoding: utf-8
class Wizard::ZonesController < ApplicationController

  def index
    @zones = Interface::Zone.all
    if request.xhr?
      render :layout => false
    end
  end

  def update
    @zone = Interface::Zone.new(params[:zone])
    @zone.save
    render '/crud/update.js', :locals => { :type => :zone, :model => @zone }
  end

  def delete
    @zone = Interface::Zone.new(params[:zone])
    if @zone.delete
      render '/crud/delete.js', :locals => { :type => :zone, :model => @zone }
    else
      render :inline => 'alert("Błąd podczas usuwania konfiguracji strefy")'
    end
  end
end
