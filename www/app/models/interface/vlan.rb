class Interface::Vlan < Interface::Base
  attr_accessor :id, :vlan_raw_device

  def initialize(params = {})
    params[:name] = 'vlan' if params[:name].blank?
    super(params)
  end

  def name=(name)
    @id = name.gsub(/^vlan/, '')
  end

  def name
    @name + @id
  end

  def to_hash
    params = { name: name, method: method }
    params[:vlan_raw_device] = vlan_raw_device unless vlan_raw_device.blank?
    params
  end

  private

  def self.allowed_interfaces
    [:VLAN]
  end
end
