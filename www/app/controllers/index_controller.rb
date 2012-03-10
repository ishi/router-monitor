class IndexController < ApplicationController
  before_filter :no_cache, :only => [:index]
  
  def index
  end

end
