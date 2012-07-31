class Zone
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name, :type, :method, :ip, :mask, :gateway, :dns, :interface
  validates :name, :presence => { :message => 'Podaj nazwe strefy' }

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  class << self
    def all
    end
  end
end
