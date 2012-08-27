class Zone
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  Interfaces_path='/app/etc/interfaces.test'
  @persisted = false

  attr_accessor :name, :old_name, :type, :method, :ip, :mask, :gateway, :dns, :interface
  validates :name, :presence => { :message => 'Podaj nazwe strefy' }
  validates :ip, :presence => { :message => 'Podaj IP dla strefy' }, :unless => :method_dhcp?
  validates :mask, 
    :presence => { :message => 'Podaj maske dla strefy' }, 
    :format => { :with => /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$/, :message => 'Niepoprawny format ip' },
    :unless => :method_dhcp?
  validates :gateway, 
    :presence => { :message => 'Dla wybranej konfiguracji typu i metody adresacji parametr jest wymagany' }, 
    :format => { :with => /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$/, :message => 'Niepoprawny format ip' },
    :if => :static_wan?
  validates :dns, 
    :presence => { :message => 'Dla wybranej konfiguracji typu i metody adresacji parametr jest wymagany' }, 
    :format => { :with => /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$/, :message => 'Niepoprawny format ip' },
    :if => :static_wan?

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def old_name
    @old_name || name
  end

  def method
    @method ||= 'DHCP'
  end

  def persisted?
    @persisted
  end

  def save
    put_file_content(replace_definition_in_file.join) if valid?
  end

  def delete
    put_file_content(remove_interface_mapping && remove_zone_definition) unless zone_name_to_save.blank?
  end

  def method_dhcp?
    'DHCP' == method
  end

  def static_wan?
    'STATIC' == method && 'WAN' == type
  end

  private

  def get_file_content
    @interfaces_content ||= self.class.get_interfaces_content
    @interfaces_content << "\n" unless @interfaces_content.last =~ /^\s*\n$/
    @interfaces_content
  end

  def put_file_content(content)
    File.open(Interfaces_path, 'w') do |f|
      f.puts content
    end
    true
  end

  def replace_definition_in_file
    remove_interface_mapping && remove_zone_definition && add_interface_mapping && add_zone_definition
  end

  def remove_zone_definition
    remove_stanza(/^\s*iface\s+(#{zone_name_to_save(old: true)}|#{old_name})\s+/)
    remove_stanza(/^\s*auto\s+(#{zone_name_to_save(old: true)}|#{old_name})\s*$/)
  end

  def remove_interface_mapping
    remove_stanza(/^\s*(mapping\s+#{interface}|auto\s+#{interface}|auto\s+#{old_name})\s*$/)
  end

  def remove_stanza pattern
    delete = false
    get_file_content.delete_if do | line |
      delete &= !self.class.stanza_line?(line)
      delete |= line =~ pattern
    end
  end

  def add_zone_definition
    content = get_file_content
    content << "auto #{zone_name_to_save}\n"
    content << "iface #{zone_name_to_save} inet #{method.downcase}\n"
    content << "#" if method_dhcp?
    content << "address #{ip}\n"
    content << "#" if method_dhcp?
    content << "netmask #{mask}\n"
    #content << "#" if method_dhcp?
    content << "#network\n"
    content << "#broadcast\n"
    content << "#" unless static_wan?
    content << "gateway #{gateway}\n"
    content << "#" unless static_wan?
    content << "dns-nameservers #{dns}\n"
    content << "#dns-search\n"
    content << "#hwaddress ether 00:01:02:a5:10:10\n"
  end

  def add_interface_mapping
    return true if interface.blank?
    get_file_content.concat [
      "mapping #{interface}\n",
      "\tscript /app/etc/zone-interface-mapping.sh\n",
      "\tmap #{zone_name_to_save}\n",
    ]
  end

  def zone_name_to_save(params = {})
    name_to_save = []
    name_to_save << (params[:old] ? old_name : name).gsub(/ /, '_')
    name_to_save << "-#{type}" unless type.blank?
    name_to_save.join
  end

  class << self
    def all
      @zones ||= lambda {
        zones = {}
        zone = nil
        new_zone = false
        interface_file_lines = get_interfaces_content

        while line = interface_file_lines.shift do
          zone = nil if stanza_line? line
          if mapping_lines_start? line
            zone = parse_mapping_lines line, interface_file_lines, zones
            next
          end

          if address_lines_start? line
            zone = parse_address_lines line, interface_file_lines, zones
            next
          end
          next if zone.nil?
          if line =~ /^\s*address\s+(.+)\s*$/ then zone.ip = $1 and next end
          if line =~ /^\s*netmask\s+(.+)\s*$/ then zone.mask = $1 and next end
          if line =~ /^\s*gateway\s+(.+)\s*$/ then zone.gateway = $1 and next end
          if line =~ /^\s*dns-nameservers\s+(.+)\s*$/ then zone.dns = $1 and next end
        end
        zones.values
      }.call
    end

    def interfaces
      @interfaces ||= [''] + `ip l | grep -ve '^\s' | cut -d' ' -f 2 |  tr ':\n' ' '`.split(/\s+/)
    end

    def get_interfaces_content
      File.readlines(Interfaces_path)
    end

    def stanza_line? line
      line =~ /^\s*(auto\s+|allow-|iface\s+|mapping\s+|source\s+)/
    end

    def mapping_lines_start? line
      line =~ /^\s*mapping/
    end

    def parse_mapping_lines line, interface_file_lines, zones
      line =~ /^\s*mapping\s+(\w+)\s*$/
      interface = $1
      interface_file_lines.shift
      interface_file_lines.shift =~ /^\s*map*\s+([^\s]+)\s*$/
      name, type = $1.gsub(/_/, ' ').split '-'
      find_or_create_zone zones, {:interface => interface, :name => name, :type => type}
    end

    def address_lines_start? line
      line =~ /^\s*iface\s/
    end

    def parse_address_lines line, interface_file_lines, zones
      line =~ /^\s*iface\s+([^\s]+)\s+\w+\s+(\w+)\s*$/
      method = $2.upcase
      name, type = $1.gsub(/_/, ' ').split '-'
      find_or_create_zone zones, {:name => name, :type => type, :method => method}
    end

    private

    def find_or_create_zone zones, params
      zones[:"#{params[:name]}"] ||= Zone.new(params) unless !params[:name]
    end
  end
end
