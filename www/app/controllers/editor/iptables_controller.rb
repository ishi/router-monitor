#encoding: UTF-8

class Editor::IptablesController < ApplicationController
  def show
    redirect_to :action => :edit
  end

  def edit
    @rules = Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = Array.new } }
    Dir.foreach(conf_dir) do |filename|
      next if (File.directory?(filename) || (/[^.]\.[^.]/ =~ filename).nil?)
      
      interface, chain = filename.split /\./
      @rules[interface.to_sym][chain.to_sym] += (File.open(File.join(conf_dir, filename)).readlines.map { |v| v.strip })
    end
  end

  def update
    @rules = params[:rules]
    return render :edit, :flash => { :error => 'Brak danych do zapisu' } if @rules.blank?
    
    @rules.each do |interface, chains|
      chains.each do |chain, rules|
        filename = File.join(conf_dir, "#{interface}.#{chain}")
        begin
          File.open(filename, 'w') {|f| f.write(rules.join "\n") }
        rescue
          return render :edit, :flash => { :error => "Nie udało się zapisać pliku #{filename}" }
        end
      end
    end
    
    flash[:notice] = 'Reguły zostały zapisane'
    redirect_to :action => 'edit'
  end
  
  private
  
  def conf_dir
    @dir ||= File.join('/app', 'etc', 'epp')
  end

end
