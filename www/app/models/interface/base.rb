class Interface::Base
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  @persisted = false

  attr_accessor :name, :old_name, :method, :method, :address, :netmask, :gateway, :dns_nameservers
  validates :name,
    :presence => { :message => 'Podaj nazwe strefy' }, 
    :format => { :without => /-/, :message => 'Nazwa nie moze zawierac znakow [-]' }
  validates :address, :presence => { :message => 'Podaj IP dla strefy' }, :unless => :method_dhcp?
  validates :netmask, 
    :presence => { :message => 'Podaj maske dla strefy' }, 
    :format => { :with => /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$/, :message => 'Niepoprawny format ip' },
    :unless => :method_dhcp?

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value) if respond_to?(:"#{name}")
    end
  end

  def old_name
    @old_name || name
  end

  def method=(method)
    @method = method.upcase
  end

  def method
    @method ||= 'DHCP'
  end

  def method_dhcp?
    'DHCP' == method
  end

  def persisted?
    @persisted
  end

  def save
    writer = INTERFACES::Writer.new
    params = to_save
    Interface::Zone.all.map do |zone|
      params.merge! zone.to_save if name.eql? zone.interface
    end
    Rails.logger.debug "Parametry do zapisania #{params}"
    writer.save_interface params
  end

  def delete
    writer = INTERFACES::Writer.new
    Interface::Zone.all.map do |zone|
       zone.interface = nil if name.eql? zone.interface
       zone.save
    end
    Rails.logger.debug "Parametry do usuniecia #{to_save}"
    writer.remove_interface to_save
  end

  def to_save
    params = { name: name, method: method, old_name: old_name }
    params
  end

  def to_hash
    to_save
  end

  def params
    INTERFACES::Writer.drop_non_params to_hash
  end

  def self.all
    find
  end

  def self.find options = {}
    interfaces = {}
    interfaces_arr = INTERFACES::Reader.new.parse

    interfaces_arr.map do |key, entry|
      next if interfaces.include? entry[:name]
      int = Interface::Factory.create(entry)
      interfaces[int.name] = int
      if not entry[:interface].blank?
        int_params = (interfaces_arr[entry[:interface]] || {}).merge(entry).merge({:name => entry[:interface]})
        int = Interface::Factory.create(int_params)
        interfaces[int.name] = int
      end
    end

    return interfaces[options[:name]] unless options[:name].blank?

    allowed = options[:type] || allowed_interfaces
    denied = [Interface::Zone] - allowed
    interfaces.map do |key, entry|
      entry if entry.class_in?(allowed) and not entry.class_in?(denied)
    end.compact
  end

  def class_in? array
    array.any? { |e| self.kind_of? e }
  end

  private

  def self.allowed_interfaces
   [self]
  end
end
