class Zone
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  Interfaces_path='/app/etc/interfaces.test'
  @persisted = false

  attr_accessor :name, :type, :method, :ip, :mask, :gateway, :dns, :interface
  validates :name, :presence => { :message => 'Podaj nazwe strefy' }
  validates :ip, :presence => { :message => 'Podaj IP dla strefy' }, :unless => :method_dhcp?
  validates :mask, :presence => { :message => 'Podaj maske dla strefy' }, :unless => :method_dhcp?

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def method
    @method ||= 'DHCP'
  end

  def persisted?
    @persisted
  end

  def save
    return false unless valid?
    return true
  end

  def method_dhcp?
    'DHCP' == method
  end

  class << self
    def all
      @zones ||= lambda {
        zones = {}
        zone = nil
        new_zone = false
        interface_file_lines = File.readlines(Interfaces_path)

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

    private

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
      Rails.logger.debug line =~ /^\s*iface\s+([^\s]+)\s+\w+\s+(\w+)\s*$/
      method = $2.upcase
      name, type = $1.gsub(/_/, ' ').split '-'
      find_or_create_zone zones, {:name => name, :type => type, :method => method}
    end

    def find_or_create_zone zones, params
      return nil if !params[:name]
      zones[:"#{params[:name]}"] ||= Zone.new(params)
    end
  end
end
