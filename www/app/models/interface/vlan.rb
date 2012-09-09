class Interface::Vlan < Interface::Base
  attr_accessor :id, :vlan_raw_device

  def name=(name)
    @name = name.sub(/[0-9]*$/, '')
    @id = name.sub(/^.*?([0-9]*)$/, '\1') if @id.blank?
  end

  def name
    (@name ||= 'vlan') + id
  end

  def to_save
    params = super
    params[:vlan_raw_device] = vlan_raw_device unless vlan_raw_device.blank?
    params
  end

  def to_hash
    super.merge({ :name => @name, :id => @id, :type => 'VLAN'})
  end

  private

  def self.allowed_interfaces
    [:VLAN]
  end
end
