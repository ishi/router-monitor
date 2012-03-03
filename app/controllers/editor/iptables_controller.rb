class Editor::IptablesController < ApplicationController
  def show
    redirect_to :action => :edit
  end

  def edit
    @rules = Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = Array.new } }
    dir = File.join('/app', 'etc', 'epp')
    Dir.foreach(dir) do |filename|
      next if (File.directory?(filename) || (/[^.]\.[^.]/ =~ filename).nil?)
      
      interface, chain = filename.split /\./
      @rules[interface.to_sym][chain.to_sym] += (File.open(File.join(dir, filename)).readlines.map { |v| v.strip })
    end
    puts @rules
  end

  def update
    @rules = params[:rules]
    render :edit
  end

end
