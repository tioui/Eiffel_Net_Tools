note
	description: "[
					Information of a network interfaces.
					Must use a {NET_INTERFACE_FACTORY} to get the local host interfaces.
					POSIX version.
				]"
	author: "Louis Marchand"
	date: "Thu, 19 Apr 2018 18:10:33 +0000"
	revision: "0.1"
class
	NET_INTERFACE

inherit
	ANY
	MEMORY_STRUCTURE
		export
			{NONE} all
		end

create {NET_INTERFACE_FACTORY}
	make_by_ifaddrs

feature {NONE} -- Initialization

	make_by_ifaddrs(a_item:POINTER; a_factory:NET_INTERFACE_FACTORY)
			-- Initialization of `Current' using `a_item' as `item' and
			-- `a_factory' as `factory'
		require
			Item_not_void: not a_item.is_default_pointer
			Factory_No_Error: not a_factory.has_error
		do
			make_by_pointer (a_item)
			factory := a_factory
		ensure
			Shared: shared
			Item_Is_Set: item ~ a_item
			Factory_Is_Set: factory ~ a_factory
		end

feature -- Access

	name:READABLE_STRING_GENERAL
			-- The text indentifier of `Current'
		local
			l_pointer:POINTER
			l_c_name:C_STRING
		do
			l_pointer := get_ifaddrs_struct_ifa_name(item)
			if l_pointer.is_default_pointer then
				Result := ""
			else
				create l_c_name.make_shared_from_pointer (l_pointer)
				Result := l_c_name.string
			end

		end

	address: detachable INET_ADDRESS
			-- The IP address of `Current', if any
		local
			l_inet_factory:INET_ADDRESS_FACTORY
			l_pointer:POINTER
			l_host_name_c:C_STRING
			l_erreur:INTEGER
		do
			l_pointer := get_ifaddrs_struct_ifa_addr(item)
			if not l_pointer.is_default_pointer then
				create l_inet_factory
				Result := l_inet_factory.create_from_sockaddr (l_pointer)
				create l_host_name_c.make_empty (1024)

				if attached {INET4_ADDRESS} Result then
					l_erreur := c_getnameinfo (l_pointer, c_sizeof_sockaddr_in, l_host_name_c.item, 1024, create {POINTER}, 0, 0)
					if l_erreur = 0 then
						create {INET4_ADDRESS} Result.make_from_host_and_address (l_host_name_c.string, Result.raw_address)
					end
				elseif attached {INET6_ADDRESS} Result then
					l_erreur := c_getnameinfo (l_pointer, c_sizeof_sockaddr_in6, l_host_name_c.item, 1024, create {POINTER}, 0, 0)
					if l_erreur = 0 then
						create {INET6_ADDRESS} Result.make_from_host_and_address (l_host_name_c.string, Result.raw_address)
					end
				end
			end
		end


	netmask: detachable INET_ADDRESS
			-- The IP address mask of `Current', if any
		local
			l_inet_factory:INET_ADDRESS_FACTORY
			l_pointer:POINTER
		do
			l_pointer := get_ifaddrs_struct_ifa_netmask(item)
			if not l_pointer.is_default_pointer then
				create l_inet_factory
				Result := l_inet_factory.create_from_sockaddr (l_pointer)
			end
		end


feature {NONE} -- Implementation

	structure_size: INTEGER
			-- <Precursor>
		do
			Result := c_sizeof_ifaddrs
		end

	factory:NET_INTERFACE_FACTORY
			-- The {NET_INTERFACE_FACTORY} is kept here to be certain that `Current' is not freed

feature {NONE} -- Externals

	frozen c_sizeof_ifaddrs: INTEGER
			-- Size of an ifaddrs C structure.
		external
			"C inline use <ifaddrs.h>"
		alias
			"sizeof (struct ifaddrs)"
		end

	frozen get_ifaddrs_struct_ifa_addr(ifaddrs:POINTER):POINTER
			-- Extracting the `address' C representation from `ifaddrs'
		external
			"C [struct <ifaddrs.h>] (struct ifaddrs):struct sockaddr *"
		alias
			"ifa_addr"
		end

	frozen get_ifaddrs_struct_ifa_netmask(ifaddrs:POINTER):POINTER
			-- Extracting the `netmask' C representation from `ifaddrs'
		external
			"C [struct <ifaddrs.h>] (struct ifaddrs):struct sockaddr *"
		alias
			"ifa_netmask"
		end

	frozen get_ifaddrs_struct_ifa_name(ifaddrs:POINTER):POINTER
			-- Extracting the `name' C representation from `ifaddrs'
		external
			"C [struct <ifaddrs.h>] (struct ifaddrs):char *"
		alias
			"ifa_name"
		end

	frozen c_getnameinfo(a_sockaddr:POINTER; a_addrlen:INTEGER; a_host:POINTER; a_hostlen:INTEGER; a_serv:POINTER; a_servlen, a_flags:INTEGER):INTEGER
			-- Free the host interface addresse list `a_ifap'
		external
			"C (const struct sockaddr *, socklen_t, char *, socklen_t, char *, socklen_t, int):int | <sys/socket.h>, <netdb.h>"
		alias
			"getnameinfo"
		end

	frozen c_sizeof_sockaddr_in: INTEGER
			-- Size of an ifaddrs C structure.
		external
			"C inline use <sys/socket.h>"
		alias
			"sizeof (struct sockaddr_in)"
		end

	frozen c_sizeof_sockaddr_in6: INTEGER
			-- Size of an ifaddrs C structure.
		external
			"C inline use <sys/socket.h>"
		alias
			"sizeof (struct sockaddr_in6)"
		end


end
