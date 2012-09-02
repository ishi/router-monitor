module INTERFACES
  Interfaces_path='/app/etc/interfaces.test'

  def get_file_content
    @file_content ||= lambda do
      content = File.readlines(Interfaces_path)
      content << "\n" unless content.last =~ /^\s*\n$/
      content
    end.call
  end

  def stanza_line? line
    line =~ /^\s*(auto\s+|allow-|iface\s+|mapping\s+|source\s+)/
  end

  private

  def is_blank? param
    param.nil? || param.empty?
  end
end
