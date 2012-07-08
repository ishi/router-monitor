class Zone
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name, :type, :ip, :mask, :gateway, :dns, :interface

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
      [Zone.new, Zone.new]
    end
  end
end
