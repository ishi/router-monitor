module LayoutHelper
  def javascript_jquery_ready(&script)
	content_for(:javascript_jquery_ready) {
	  capture(&script).gsub(/(<script>|<\/script>)/, "")
	}
  end
  
  def javascript_include (script_name)
	content_for(:javascript_include) {
	  raw %(<script src="/assets/#{script_name}.js" type="text/javascript"></script>)
	}
  end
end
