class Zone
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  @persisted = false

  attr_accessor :name, :old_name, :type, :method, :address, :netmask, :gateway, :dns_nameservers, :interface
  validates :name,
    :presence => { :message => 'Podaj nazwe strefy' }, 
    :format => { :without => /-/, :message => 'Nazwa nie moze zawierac znakow [-]' }
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

  def old_name
    @old_name || name
  end

  def method=(method)
    @method = method.upcase
  end

  def method
    @method
  end

  def persisted?
    @persisted
  end

  def save
    return false unless valid?
    writer = INTERFACES::Writer.new
    writer.remove_definition old_name
    writer.save_interface to_hash.merge({ name: zone_name_to_save, old_name: zone_name_to_save(old: true)})
  end

  def delete
    writer = INTERFACES::Writer.new
    writer.remove_interface({
      name: zone_name_to_save,
      interface: interface}) unless zone_name_to_save.blank?
  end

  def method_dhcp?
    'DHCP' == method
  end

  def static_wan?
    'STATIC' == method && 'WAN' == type
  end

  def to_hash
    params = {
      name: name,
      type: type,
      method: method,
      interface: interface
    }
    params[:address] = address unless method_dhcp?
    params[:netmask] = netmask unless method_dhcp?
    params[:gateway] = gateway unless method_dhcp?
    params[:dns_nameservers] = dns_nameservers unless method_dhcp?
    params
  end

  private

  def zone_name_to_save(params = {})
    name_to_save = []
    name_to_save << (params[:old] ? old_name : name).gsub(/ /, '_')
    name_to_save << "-" unless type.blank?
    name_to_save << type unless type.blank? || params[:old]
    name_to_save << ".*" if params[:old]
    name_to_save.join
  end

  class << self
    def all
      @zones ||= lambda {
        interfaces = INTERFACES::Reader.new.parse

        interfaces.select {|entry| entry[:name] =~ /-/}.map! do |entry|
          (entry[:name], entry[:type]) = entry[:name].gsub(/_/, ' ').split /-/
          Zone.new entry
        end
      }.call
    end

    def interfaces
      @interfaces ||= `ip l | grep -ve '^\s' | cut -d' ' -f 2 |  tr ':\n' ' '`.split(/\s+/)
    end
  end
end
