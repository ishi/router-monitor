class Interface::Zone < Interface::Base

  attr_accessor :type, :interface, :dhcp_service, :dhcp_lower_bound, :dhcp_upper_bound
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
      method: method,
      type: type,
    })
    params[:interface] = interface unless interface.blank?
    params[:address] = address unless method_dhcp?
    params[:netmask] = netmask unless method_dhcp?
    params[:gateway] = gateway unless method_dhcp?
    params[:dns_nameservers] = dns_nameservers unless method_dhcp?
    params[:up] = []
    params[:up] << "#dhcp" unless dhcp_service.blank? or "0".eql? dhcp_service
    params
  end

  def save
    params = {}

    old_zone = Interface::Zone.find :name => old_name unless old_name.blank?
    old_int = new_int = nil
    unless old_zone.nil? or old_zone.interface.blank? or interface.eql? old_zone.interface
      old_int = Interface::Base.find(:name => old_zone.interface)
    end
    unless interface.blank?
      new_int = Interface::Base.find :name => interface 
      params.merge!(new_int.to_save) unless new_int.blank?
    end

    params.merge! to_save
    writer = INTERFACES::Writer.new
    writer.save_interface params

    old_int.save unless old_int.blank?
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
end
