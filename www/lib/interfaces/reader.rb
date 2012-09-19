module INTERFACES
  class Reader
    include INTERFACES

    def parse
      @interfaces || lambda {
        @interfaces = get_interfaces_form_system

        interface = nil
        new_interface = false
        file_lines = get_file_content

        while line = file_lines.shift do
          interface = nil if stanza_line? line
          if mapping_lines_start? line
            interface = parse_mapping_lines line, file_lines
            next
          end

          if iface_lines_start? line
            interface = parse_iface_lines line, file_lines
            next
          end
        end
        @interfaces
      }.call
    end

    def get_interfaces_form_system
      names = `ip l | grep -ve '^\s' | cut -d' ' -f 2 |  tr ':\n' ' '`.split(/\s+/)
      interfaces = {}
      names.each do |name|
        interfaces[:"#{name}"] = { name: name }
      end
      interfaces
    end

    def mapping_lines_start? line
      line =~ /^\s*mapping/
    end

    def parse_mapping_lines line, file_lines
      line =~ /^\s*mapping\s+(\w+)\s*$/
      params = {:interface => $1}
      while file_lines.shift !~ /^\s*map*\s+([^\s]+)\s*$/ do
        return if file_lines.empty?
      end

      params[:name] = $1
      find_or_create_interface params
    end

    def iface_lines_start? line
      line =~ /^\s*iface\s/
    end

    def parse_iface_lines line, file_lines
      line =~ /^\s*iface\s+([^\s]+)\s+\w+\s+(\w+)\s*$/
      params = {:method => $2.upcase, :name => $1}

      while not (file_lines.empty? || stanza_line?(file_lines[0])) do
        next unless file_lines.shift =~ /^\s*([^#]\S*)\s+(.+)\s*$/
        value = $2
        params[:"#{$1.gsub(/-/, '_')}"] = value unless $1.nil? || $1.empty?
      end

      find_or_create_interface params
    end

    def find_or_create_interface params = {}
      @interfaces[:"#{params[:name]}"] = (@interfaces[:"#{params[:name]}"] || {}).merge params if params[:name]
    end
  end
end
