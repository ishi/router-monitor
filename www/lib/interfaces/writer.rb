module INTERFACES
  class Writer
    include INTERFACES

    def save
      put_file_content(get_file_content)
    end

    def save_interface params
      remove_interface params
      remove_interface({:name => params[:old_name]}) and params.delete :old_name unless is_blank? params[:old_name]
      remove_interface({:name => params[:interface]}) unless is_blank? params[:interface]
      add_definition params
      add_mapping params
      save
    end

    def remove_interface params
      remove_mapping params[:name] unless is_blank? params[:name]
      remove_definition params[:name] unless is_blank? params[:name]
      save
    end

    def remove_mapping name
      remove_preceding_comment(/^\s*mapping\s+#{name}/)
      remove_stanza_by_param(/^\s*map\s+#{name}\s*$/)
    end

    def remove_definition name
      remove_stanza(/^\s*auto\s+#{name}\s*$/)
      remove_preceding_comment(/^\s*iface\s+#{name}\s+/)
      remove_stanza(/^\s*iface\s+#{name}\s+/)
    end

    def remove_preceding_comment pattern
      searching_for_non_comment = false
      content = get_file_content
      start_index = nil
      content.each_with_index { |line, index| start_index = index if line =~ pattern }
      return if start_index.nil?
      while start_index >=0 and content[start_index -= 1] =~ /^\s*#/
        content.delete_at start_index
      end
    end

    def remove_stanza_by_param pattern
      searching_for_stanza = false
      stanza = nil
      get_file_content.reverse_each do |line|
        if line =~ pattern
          searching_for_stanza = true
        end
        if searching_for_stanza and stanza_line? line
          remove_stanza(/^#{line}$/)
          break
        end
      end
    end

    def remove_stanza pattern
      delete = false
      get_file_content.delete_if do | line |
        delete &= !stanza_line?(line)
        delete &= line !~ /^\s*#[=:]([^\/]|$)/
        delete |= line =~ pattern
      end
    end

    def add_definition params
      return false if is_blank?(params[:name]) || is_blank?(params[:method])
      content = get_file_content
      
      content << "#:Konfiguracja #{if params[:name] =~ /-/ then 'strefy' else 'interfejsu' end } #{params[:name]}\n"
      content << "#=\n"
      content << "auto #{params[:name]}\n" if is_blank? params[:interface] and params[:name] !~ /-/
      content << "iface #{params[:name]} inet #{params[:method].downcase}\n"
      Writer.drop_non_params(params).each do |key, value|
        unless value.is_a? Array
          value = [value]
        end
        
        value.each { |v| content << "\t#{key} #{v}\n" unless is_blank? v }
      end
      content << "#=/\n" if is_blank? params[:interface]
      content << "\n"
      true
    end

    def add_mapping params
      return true if is_blank?(params[:name]) ||  is_blank?(params[:interface])
      content = get_file_content.concat [
        "auto #{params[:interface]}\n",
        "mapping #{params[:interface]}\n",
        "\tscript /app/etc/zone-interface-mapping.sh\n",
        "\tmap #{params[:name]}\n",
      ]
      content << "#=/\n"
      content << "\n"
    end

    def self.drop_non_params params
      to_remove = [:name, :old_name, :method, :type, :interface, :id]
      params.reject{|key| to_remove.include? key }
    end

    private
    def put_file_content(content)
      File.open(Interfaces_path, 'w') do |f|
        f.puts content
        true
      end
    end

  end
end

