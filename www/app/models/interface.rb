class Interface
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  @persisted = false

  attr_accessor :name, :method, :vlan_raw_device, :address, :netmask, :gateway, :dns_nameservers
  validates :name, :presence => { :message => 'Podaj nazwe interfejsu' }

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    @persisted
  end

  def save
    writer = INTERFACES::Writer.new
    writer.save_interface to_hash
  end

  def delete
    writer = INTERFACES::WRITER.new
    writer.remove_interfacer to_hash
  end

  def method_dhcp?
    'DHCP' == method
  end
  
  def to_hash
    params = { name: name, method: method }
    params[:vlan_raw_device] = vlan_raw_device unless vlan_raw_device.blank?
    params[:address] = address unless address.blank?
    params[:netmask] = netmask unless netmask.blank?
    params[:gateway] = gateway unless gateway.blank?
    params[:dns_nameservers] = dns_nameservers unless dns_nameservers.blank?
    params
  end

  private

  class << self
    def all
      @interfaces ||= lambda {
        interfaces = INTERFACES::Reader.new.parse

        interfaces.select {|entry| entry[:name] !~ /-/} .map! {|entry| Interface.new entry }
      }.call
    end
  end
end
