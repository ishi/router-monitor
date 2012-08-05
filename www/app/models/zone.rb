class Zone
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  Interfaces_path='/app/etc/interfaces.test'
  @persisted = false

  attr_accessor :name, :type, :method, :ip, :mask, :gateway, :dns, :interface
  validates :name, :presence => { :message => 'Podaj nazwe strefy' }

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    @persisted
  end

  class << self
    def all
      @zones ||= lambda {
        zones = []
        zone = nil
        new_zone = false
        File.new(Interfaces_path, "r").each_line do |line|
          zone = nil if stanza_line? line
          if new_zone? line
            zones << zone = create_zone(line) and next
          end
          next if zone.nil?
          if line =~ /^\s*address\s+(.+)\s*$/ then zone.ip = $1 and next end
          if line =~ /^\s*netmask\s+(.+)\s*$/ then zone.mask = $1 and next end
          if line =~ /^\s*gateway\s+(.+)\s*$/ then zone.gateway = $1 and next end
          if line =~ /^\s*dns-nameservers\s+(.+)\s*$/ then zone.dns = $1 and next end
        end
        zones
      }.call
    end

    def interfaces
      @interfaces ||= `ip l | grep -ve '^\s' | cut -d' ' -f 2 |  tr ':\n' ' '`.split /\s+/
    end

    private

    def stanza_line? line
      line =~ /^\*(auto |allow-|iface |mapping |source )/
    end

    def new_zone? line
      line =~ /^\s*iface/
    end

    def create_zone line
      line =~ /^\s*iface\s+(\w+)\s+\w+\s+(\w+)\s*$/
      Zone.new(:name => $1, :method => $2)
    end
  end
end
