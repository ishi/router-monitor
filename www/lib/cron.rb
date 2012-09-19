module CRON

	class Sender < EM::Connection

		def initialize(*args)
			super
			@doc = args[0]
		end

		def post_init
			send_data(@doc)
			close_connection_after_writing()
		end

		def receive_data(data)
		end

		def unbind
			EM.stop
		end

		def self.send_task(data)
			EM.run { EM.connect("localhost", 22223, Sender, data.id) }
		end
	end
end

class Object
	include CRON
end
