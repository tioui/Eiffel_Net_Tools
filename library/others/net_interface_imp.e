note
	description: "[
					Information of a network interfaces.
					Must use a {NET_INTERFACE_FACTORY} to get the local host interfaces.
					POSIX version.
				]"
	author: "Louis Marchand"
	date: "Thu, 19 Apr 2018 18:10:33 +0000"
	revision: "0.2"
deferred class
	NET_INTERFACE_IMP

inherit
	ANY
	MEMORY_STRUCTURE
		rename
			make as make_structure
		export
			{NONE} all
		end

feature {NONE} -- Initialization

	make(a_item:POINTER; a_factory:NET_INTERFACE_FACTORY_IMP)
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



feature {NONE} -- Implementation

	internal_address_sockaddr: POINTER
			-- the internal value of `address'
		do
			Result := get_ifaddrs_struct_ifa_addr(item)
		end

	internal_netmask_sockaddr: POINTER
			-- the internal value of `netmask'
		do
			Result := get_ifaddrs_struct_ifa_netmask(item)
		end


	structure_size: INTEGER
			-- <Precursor>
		do
			Result := c_sizeof_ifaddrs
		end

	factory:NET_INTERFACE_FACTORY_IMP
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
			-- Get the host name from `a_sockaddr'.
		external
			"C (const struct sockaddr *, socklen_t, char *, socklen_t, char *, socklen_t, int):int | <sys/socket.h>, <netdb.h>"
		alias
			"getnameinfo"
		end

	frozen c_sizeof_sockaddr_in: INTEGER
			-- Size of an sockaddr_in C structure.
		external
			"C inline use <sys/socket.h>"
		alias
			"sizeof (struct sockaddr_in)"
		end

	frozen c_sizeof_sockaddr_in6: INTEGER
			-- Size of an sockaddr_in6 C structure.
		external
			"C inline use <sys/socket.h>"
		alias
			"sizeof (struct sockaddr_in6)"
		end


end
