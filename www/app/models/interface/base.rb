class Interface::Base
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  @persisted = false

  attr_accessor :name, :method
  validates :name, :presence => { :message => 'Podaj nazwe interfejsu' }

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value) if respond_to?(:"#{name}")
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
    params
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
    end.delete_if { |entry| entry.nil? }
  end

  private

  def self.allowed_interfaces
   []
  end
end
