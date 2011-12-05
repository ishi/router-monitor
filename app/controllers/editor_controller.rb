#encoding: UTF-8

class EditorController < ApplicationController
  @@types = {
    'interfaces' => '/etc/network/interfaces'
  }
  before_filter :set_params
  
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
    redirect_to edit_editor_url(@type), :notice => "Zapisano plik"
  end
  
private

  def set_params
    @type = params[:type]
    redirect_to root_url, :alert => "Nieobsługiwany plik" unless @@types.has_key? @type
    @file = @@types[@type]
  end

end
