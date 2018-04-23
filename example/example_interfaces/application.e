note
	description: "An exemple of using the {NET_INTERFACE} and {NET_INTERFACE_FACTORY} classes"
	author: "Louis Marchand"
	date: "Thu, 19 Apr 2018 18:10:33 +0000"
	revision: "0.2"

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
			l_factory:NET_INTERFACE_FACTORY
		do
			create l_factory
			if l_factory.has_error then
				io.error.put_string ("An error occured: " + l_factory.error_number.out + "%N")
			else
				io.standard_default.put_string ("Interface IPv4:%N")
				print_interfaces(l_factory.inet4_interfaces)
				io.standard_default.put_string ("Interface IPv6:%N")
				print_interfaces(l_factory.inet6_interfaces)
			end
		end

	print_interfaces(a_interfaces:LIST[NET_INTERFACE])
			-- Print every `a_interfaces' to the console
		do
			across a_interfaces as la_interfaces loop
				io.standard_default.put_string ("%T" + la_interfaces.item.name + "%N")
				if attached la_interfaces.item.address as la_address then
					io.standard_default.put_string ("%T%Taddress: " + la_address.host_address + "%N")
					io.standard_default.put_string ("%T%Thost: " + la_address.host_name + "%N")
				end
				if attached la_interfaces.item.netmask as la_netmask then
					io.standard_default.put_string ("%T%Tnetmask: " + la_netmask.host_address + "%N")
				end
				io.standard_default.put_new_line
			end
		end

end
