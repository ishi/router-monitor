class Interface::Factory
  def self.create params, allowed_types = []
    Rails.logger.debug "Otrzymane parametry #{params}"
    case params[:name]
    when /^vlan/
      Rails.logger.debug "Wybieram VLAN"
      Interface::Vlan.new(params) if allowed? :VLAN, allowed_types
    when /^br/
      Rails.logger.debug "Wybieram BRIDGE"
      Interface::Bridge.new(params) if allowed? :BRIDGE, allowed_types
    else
      Rails.logger.debug "Wybieram BASE"
      Interface::Base.new(params) if allowed? :INT, allowed_types
    end
  end
  
  private
  def self.allowed? type, allowed_types
    allowed_types.blank? || allowed_types.include?(type)
  end
end
