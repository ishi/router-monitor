class Interface::Factory
  def self.create params, allowed_types = [], denied_types = []
    #Rails.logger.debug "Otrzymane parametry #{params}"
    case params[:name]
    when /-/
      #Rails.logger.debug "Wybieram ZONE"
      params[:name], params[:type] = params[:name].gsub(/_/, ' ').split /-/
      Interface::Zone.new(params)
    when /^vlan/
      #Rails.logger.debug "Wybieram VLAN"
      Interface::Vlan.new(params)
    when /^br/
      #Rails.logger.debug "Wybieram BRIDGE"
      Interface::Bridge.new(params)
    else
      #Rails.logger.debug "Wybieram PHYSICAL"
      Interface::Physical.new(params)
    end
  end
end
