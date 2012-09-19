class Interface::Bridge < Interface::Base
  attr_accessor :id, :bridge_ports, :bridge_fd, :bridge_hello, :bridge_maxage, :bridge_stp, :bridge_maxwait

  def name=(name)
    @name = name.sub(/[0-9]*$/, '')
    @id = name.sub(/^.*?([0-9]*)$/, '\1') if @id.blank?
  end

  def name
    (@name ||= 'br') + id
  end

  def to_save
    params = super
    params[:bridge_maxwait] = bridge_maxwait unless bridge_maxwait.blank?
    params[:bridge_ports] = bridge_ports unless bridge_ports.blank?
    params[:bridge_fd] = bridge_fd unless bridge_fd.blank?
    params[:bridge_hello] = bridge_hello unless bridge_hello.blank?
    params[:bridge_maxage] = bridge_maxage unless bridge_maxage.blank?
    params[:bridge_stp] = bridge_stp unless bridge_stp.blank?
    params
  end

  def to_hash
    super.merge({ :name => @name, :id => @id, :type => 'BRIDGE'})
  end
end
