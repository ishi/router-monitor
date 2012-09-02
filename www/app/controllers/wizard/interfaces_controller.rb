# encoding: utf-8
class Wizard::InterfacesController < ApplicationController

  def index
    @interfaces = Interface.all
    if request.xhr?
      render :layout => false
    end
  end

  def update
    @zone = Interfaces.new(params[:interface])
    @zone.save
  end

  def delete
    @zone = Interfaces.new(params[:interface])
    respond_to do |format|
      if @zone.delete
        format.js
      else
        format.js { render :inline => 'alert("Błąd podczas usuwania konfiguracji interfejsu")'}
      end
    end
  end
end
