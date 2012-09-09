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
    render '/crud/update.js', :locals => { :type => :interface, :model => @interface }
  end

  def delete
    @interface = Interface::Factory.create(params[:interface])
    if @interface.delete
      render '/crud/delete.js', :locals => { :type => :interface, :model => @interface }
    else
      render :inline => 'alert("Błąd podczas usuwania konfiguracji interfejsu")'
    end
  end
end
