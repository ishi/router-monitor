class Interface
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  @persisted = false

  attr_accessor :name, :type, :method, :address, :netmask, :gateway, 
    :dns_nameservers, :interface, :vlan_raw_device
  validates :name, :presence => { :message => 'Podaj nazwe strefy' }
  validates :address, :presence => { :message => 'Podaj IP dla strefy' }, :unless => :method_dhcp?
  validates :netmask, 
    :presence => { :message => 'Podaj maske dla strefy' }, 
    :format => { :with => /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$/, :message => 'Niepoprawny format ip' },
    :unless => :method_dhcp?
  validates :gateway, 
    :presence => { :message => 'Dla wybranej konfiguracji typu i metody adresacji parametr jest wymagany' }, 
    :format => { :with => /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$/, :message => 'Niepoprawny format ip' },
    :if => :static_wan?
  validates :dns_nameservers, 
    :presence => { :message => 'Dla wybranej konfiguracji typu i metody adresacji parametr jest wymagany' }, 
    :format => { :with => /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$/, :message => 'Niepoprawny format ip' },
    :if => :static_wan?

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
    writer = INTERFACES::Writer.new
    writer.remove_definition old_name
    writer.save_interface({ 
      name: zone_name_to_save,
      old_name: zone_name_to_save(old: true),
      method: method,
      interface: interface, 
      address: address,
      netmask: netmask,
      gateway: gateway,
      dns_nameservers: dns_nameservers
       })
  end

  def delete
    writer = INTERFACES::WRITER.new
    writer.remove_interfacer({
      name: zone_name_to_save, 
      interface: initialize}) unless zone_name_to_save.blank?
  end

  def method_dhcp?
    'DHCP' == method
  end

  def static_wan?
    'STATIC' == method && 'WAN' == type
  end

  private

  def zone_name_to_save(params = {})
    name_to_save = []
    name_to_save << (params[:old] ? old_name : name).gsub(/ /, '_')
    name_to_save << "-#{type}" unless type.blank?
    name_to_save.join
  end

  class << self
    def all
      @interfaces ||= lambda {
        interfaces = INTERFACES::Reader.new.parse

        interfaces.select {|entry| entry[:name] !~ /-/} .map! {|entry| Interface.new entry }
      }.call
    end

    def interfaces
      @interfaces ||= [''] + `ip l | grep -ve '^\s' | cut -d' ' -f 2 |  tr ':\n' ' '`.split(/\s+/)
    end
  end
end
