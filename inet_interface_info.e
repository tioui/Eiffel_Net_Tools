note
	description: "Info of a network interfaces"
	author: "Louis Marchand"
	date: "Thu, 19 Apr 2018 18:10:33 +0000"
	revision: "0.1"

class
	INET_INTERFACE_INFO

inherit
	ANY
	MEMORY_STRUCTURE
		export
			{NONE} all
		end

create {INET_INTERFACE_FACTORY}
	make_by_ifaddrs

feature {NONE} -- Initialization

	make_by_ifaddrs(a_item:POINTER; a_factory:INET_INTERFACE_FACTORY)
			--
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
		do
			l_pointer := get_ifaddrs_struct_ifa_addr(item)
			if not l_pointer.is_default_pointer then
				create l_inet_factory
				Result := l_inet_factory.create_from_sockaddr (l_pointer)
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

	factory:INET_INTERFACE_FACTORY
			-- The {INET_INTERFACE_FACTORY} is kept here to be certain that `Current' is not freed

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

end
