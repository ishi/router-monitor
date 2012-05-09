#encoding: UTF-8

class Editor::ConfigsController < ApplicationController
  @@types = {
    'interfaces' => '/etc/network/interfaces'
  }
  before_filter :set_params
  
  def show
    redirect_to :action => :show
  end

  def edit
    @content = ''
    return unless 
    File.open(@file, "r") do |io|
      while (line = io.gets)
        @content += line
      end
    end
  rescue => err
    Rails.logger.error "Exception: #{err}"
  end

  def update
    puts params
    if params[:commit] == 'Otwórz'
      self.edit
      render 'edit'
      return
    end
    redirect_to edit_config_url(@type), :notice => "Zapisano plik"
  end
  
private

  def set_params
    @type = params[:type]
    #redirect_to root_url, :alert => "Nieobsługiwany plik" unless @@types.has_key? @type
    @file = !params[:file].blank? && params[:file] || @@types[@type]
  end

end
