class Interface::Factory
  def self.create params, types = []
    case params[:name]
    when /^vlan[0-9]{1,3}/
      Interface::Vlan.new(params) if allowed? :VLAN, types
    else
      Interface::Base.new(params) if allowed? :INT, types
    end
  end
  
  private
  def self.allowed? type, types
    types.blank? || types.include?(type)
  end
end
