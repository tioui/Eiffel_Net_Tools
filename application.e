note
	description: "net_tools application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			l_factory:INET_INTERFACE_FACTORY
		do
			create l_factory
			if l_factory.has_error then
				io.error.put_string ("An error occured: " + l_factory.error_message)
			else
				across l_factory.interfaces as la_interfaces loop
					print("Interface: " + la_interfaces.item.name + "%N")
					if attached la_interfaces.item.address as la_address then
						print("%T" + la_address.host_name + "%N")
					end
				end
			end
		end

end
