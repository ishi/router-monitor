class Interface::Zone < Interface::Base
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  @persisted = false

  attr_accessor :type, :address, :netmask, :gateway, :dns_nameservers, :interface
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

  def static_wan?
    'STATIC' == method && 'WAN' == type
  end

  def to_save
    params = super.merge({
      name: zone_name_to_save,
      old_name: zone_name_to_save(old: true),
      type: type,
      interface: interface
    })
    params[:address] = address unless method_dhcp?
    params[:netmask] = netmask unless method_dhcp?
    params[:gateway] = gateway unless method_dhcp?
    params[:dns_nameservers] = dns_nameservers unless method_dhcp?
    params
  end

  def to_hash
    super.merge({:name => name, :old_name => old_name})
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
          Interface::Zone.new entry
        end
      }.call
    end
  end
end
