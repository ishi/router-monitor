class Zone
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  Interfaces_path='/app/etc/interfaces.test'
  @persisted = false

  attr_accessor :name, :old_name, :type, :method, :ip, :mask, :gateway, :dns, :interface
  validates :name, :presence => { :message => 'Podaj nazwe strefy' }
  validates :ip, :presence => { :message => 'Podaj IP dla strefy' }, :unless => :method_dhcp?
  validates :mask, :presence => { :message => 'Podaj maske dla strefy' }, :unless => :method_dhcp?

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
    replace_definition_in_file if valid?
    Rails.logger.debug get_file_content.join
  end

  def method_dhcp?
    'DHCP' == method
  end

  private

  def get_file_content
    @interfaces_content ||= self.class.get_interfaces_content
  end

  def replace_definition_in_file
    remove_interface_mapping && remove_zone_definition && add_interface_mapping && add_zone_definition
  end

  def remove_zone_definition
    remove_stanza(/^\s*iface\s+(#{zone_name_to_save(old: true)}|#{old_name})\s+/)
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
    content << "iface #{zone_name_to_save} inet #{method.downcase}\n"
    content << "#" if method_dhcp?
    content << "address #{ip}\n"
    content << "#" if method_dhcp?
    content << "netmask #{mask}\n"
    content << "#" if method_dhcp?
    content << "#network 153.19.250.128\n"
    content << "#broadcast 153.19.250.143\n"
    content << "#" if method_dhcp?
    content << "gateway #{gateway}\n"
    content << "#" if method_dhcp?
    content << "dns-nameservers #{dns}\n"
    content << "#dns-search\n"
    content << "#hwaddress ether 00:01:02:a5:10:10\n"
    content << "\n"
  end

  def add_interface_mapping
    return true if interface.blank?
    get_file_content.concat [
      "mapping #{interface}\n",
      "\tscript /app/etc/zone-interface-mapping.sh\n",
      "\tmap #{zone_name_to_save}\n",
      "\n"
    ]
  end

  def zone_name_to_save(params = {})
    "#{(params[:old] ? old_name : name).gsub(/ /, '_')}-#{type}"
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
