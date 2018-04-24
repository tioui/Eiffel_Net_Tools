note
	description: "[
					Information of a network interfaces.
					Must use a {NET_INTERFACE_FACTORY} to get the local host interfaces.
					POSIX version.
				]"
	author: "Louis Marchand"
	date: "Thu, 19 Apr 2018 18:10:33 +0000"
	revision: "0.2"
class
	NET_INTERFACE

inherit
	NET_INTERFACE_IMP
		redefine
			out
		end

create {NET_INTERFACE_FACTORY_IMP}
	make

feature -- Access

	address: detachable INET_ADDRESS
			-- The IP address of `Current', if any
		local
			l_inet_factory:INET_ADDRESS_FACTORY
			l_pointer:POINTER
			l_host_name_c:C_STRING
			l_erreur:INTEGER
		do
			l_pointer := internal_address_sockaddr
			if not l_pointer.is_default_pointer then
				create l_inet_factory
				Result := l_inet_factory.create_from_sockaddr (l_pointer)
				if attached {INET4_ADDRESS} Result then
					create l_host_name_c.make_empty (1024)
					l_erreur := c_getnameinfo (l_pointer, c_sizeof_sockaddr_in, l_host_name_c.item, 1024, create {POINTER}, 0, 0)
					if l_erreur = 0 then
						create {INET4_ADDRESS} Result.make_from_host_and_address (l_host_name_c.string, Result.raw_address)
					end
				elseif attached {INET6_ADDRESS} Result then
					create l_host_name_c.make_empty (1024)
					l_erreur := c_getnameinfo (l_pointer, c_sizeof_sockaddr_in6, l_host_name_c.item, 1024, create {POINTER}, 0, 0)
					if l_erreur = 0 then
						create {INET6_ADDRESS} Result.make_from_host_and_address (l_host_name_c.string, Result.raw_address)
					end
				end

			end

		end



	out:STRING
			-- <Precursor>
		do
			Result := name.to_string_8
			if attached address as la_address then
				Result := Result + " <" + la_address.host_name
				if attached netmask as la_netmask then
					Result := Result + "/" + la_netmask.host_name
				end
				Result := Result + ">"
			end

		end

end
