module INTERFACES
  class Writer
    include INTERFACES

    def save
      put_file_content(get_file_content)
    end

    def save_interface params
      remove_mapping params[:interface] unless is_blank? params[:interface]
      remove_definition params[:old_name] and params.delete :old_name unless is_blank? params[:old_name]
      add_mapping params
      add_definition params
      save
    end

    def remove_interface params
      remove_mapping params[:interface] unless is_blank? params[:interface]
      remove_definition params[:name] unless is_blank? params[:name]
      save
    end

    def remove_mapping interface
      remove_stanza(/^\s*mapping\s+#{interface}\s*$/)
    end

    def remove_definition name
      remove_stanza(/^\s*iface\s+#{name}\s+/)
      remove_stanza(/^\s*auto\s+#{name}\s*$/)
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
      params[:method].downcase!
      content = get_file_content
      content << "auto #{params[:name]}\n"
      content << "iface #{params[:name]} inet #{params[:method]}\n"
      content << "vlan-raw-device #{params[:vlan_raw_device]}" unless is_blank? params[:vlan_raw_device]
      content << "address #{params[:address]}\n" unless is_blank? params[:address]
      content << "netmask #{params[:netmask]}\n" unless is_blank? params[:netmask]
      content << "gateway #{params[:gateway]}\n" unless is_blank? params[:gateway]
      content << "dns-nameservers #{params[:dns_nameservers]}\n" unless is_blank? params[:dns_nameservers]
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
      end
    end

  end
end
