class Interface::Base
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  @persisted = false

  attr_accessor :name, :old_name, :method
  validates :name,
    :presence => { :message => 'Podaj nazwe strefy' }, 
    :format => { :without => /-/, :message => 'Nazwa nie moze zawierac znakow [-]' }

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

  def persisted?
    @persisted
  end

  def save
    writer = INTERFACES::Writer.new
    writer.save_interface to_save
  end

  def delete
    writer = INTERFACES::Writer.new
    writer.remove_interface to_save
  end

  def method_dhcp?
    'DHCP' == method
  end

  def to_save
    params = { name: name, method: method, old_name: old_name }
    params
  end

  def to_hash
    to_save
  end

  def self.all
    find
  end

  def self.find options = {}
    @@interfaces ||= lambda do
      interfaces = INTERFACES::Reader.new.parse
      interfaces.select {|entry| entry[:name] !~ /-/}
    end.call

    @@interfaces.map do |entry|
      Interface::Factory.create(entry, allowed_interfaces.concat(options[:type] || []))
    end.compact
  end

  private

  def self.allowed_interfaces
   []
  end
end
