class Interface::Bridge < Interface::Base
  attr_accessor :id, :bridge_ports, :bridge_fd, :bridge_hello, :bridge_maxage, :bridge_stp

  def name=(name)
    @name = name.sub(/[0-9]*$/, '')
    @id = name.sub(/^.*?([0-9]*)$/, '\1') if @id.blank?
  end

  def name
    (@name ||= 'br') + id
  end

  def bridge_fd
    @bridge_fd ||= '9'
  end

  def bridge_hello
    @bridge_hello ||= '2'
  end

  def bridge_maxage
    @bridge_maxage ||= '12'
  end

  def bridge_stp
    @bridge_stp ||= 'off'
  end

  def to_save
    params = super
    params[:bridge_ports] = bridge_ports unless bridge_ports.blank?
    params[:bridge_fd] = bridge_fd unless bridge_fd.blank?
    params[:bridge_hello] = bridge_hello unless bridge_hello.blank?
    params[:bridge_maxage] = bridge_maxage unless bridge_maxage.blank?
    params[:bridge_stp] = bridge_stp unless bridge_stp.blank?
    Rails.logger.debug "Parametry do zapisania #{params}"
    params
  end

  def to_hash
    super.merge({ :name => @name, :id => @id, :type => 'BRIDGE'})
  end

  private

  def self.allowed_interfaces
    [:BRIDGE]
  end
end
