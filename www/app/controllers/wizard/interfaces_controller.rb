# encoding: utf-8
class Wizard::InterfacesController < ApplicationController

  def index
    @interfaces = Interface::Base.all
    if request.xhr?
      render :layout => false
    end
  end

  def update
    @interface = Interface::Factory.create(params[:interface])
    @interface.save
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
