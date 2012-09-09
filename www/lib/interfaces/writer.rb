module INTERFACES
  class Writer
    include INTERFACES

    def save
      put_file_content(get_file_content)
    end

    def save_interface params
      remove_interface params
      remove_interface params.merge({:name => params[:old_name]}) and params.delete :old_name unless is_blank? params[:old_name]
      add_mapping params
      add_definition params
      save
    end

    def remove_interface params
      remove_mapping params[:name] unless is_blank? params[:name]
      remove_definition params[:name] unless is_blank? params[:name]
      save
    end

    def remove_mapping name
      remove_stanza_by_param(/^\s*map\s+#{name}\s*$/)
    end

    def remove_definition name
      remove_stanza(/^\s*iface\s+#{name}\s+/)
      remove_stanza(/^\s*auto\s+#{name}\s*$/)
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
        delete |= line =~ pattern
      end
    end

    def add_definition params
      return false if is_blank?(params[:name]) || is_blank?(params[:method])
      content = get_file_content
      content << "auto #{params[:name]}\n"
      content << "iface #{params[:name]} inet #{params[:method].downcase}\n"
      to_remove = [:name, :old_name, :method]
      params.reject{|key| to_remove.include? key }.each do |key, value|
        content << "\t#{key} #{value}" unless is_blank? value
      end
      content << "\n"
      true
    end

    def add_mapping params
      return true if is_blank?(params[:name]) ||  is_blank?(params[:interface])
      get_file_content.concat [
        "mapping #{params[:interface]}\n",
        "\tscript /app/etc/zone-interface-mapping.sh\n",
        "\tmap #{params[:name]}\n\n",
      ]
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
