note
	description: "[
					Information of a network interfaces.
					Must use a {NET_INTERFACE_FACTORY} to get the local host interfaces.
					Windows version.
				]"
	author: "Louis Marchand"
	date: "Thu, 19 Apr 2018 18:10:33 +0000"
	revision: "0.1"
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

	make(
				a_item, a_address_sockaddr:POINTER;
				a_factory:NET_INTERFACE_FACTORY_IMP;
				a_netmask:detachable INET_ADDRESS
			)
			-- Initialization of `Current' using `a_item' as `item' and
			-- `a_factory' as `factory'
		require
			Item_not_void: not a_item.is_default_pointer
			Factory_No_Error: not a_factory.has_error
		do
			make_by_pointer (a_item)
			factory := a_factory
			internal_address_sockaddr := a_address_sockaddr
			netmask := a_netmask
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
			l_converter:UTF_CONVERTER
			l_managed_pointer:MANAGED_POINTER
		do
			create l_converter
			l_pointer := get_adapter_addresses_struct_friendlyname(item)
			create l_managed_pointer.share_from_pointer (l_pointer, 1024)
			Result := l_converter.utf_16_0_pointer_to_string_32 (l_managed_pointer)
		end

	netmask:detachable INET_ADDRESS
			-- The IP address mask of `Current', if any
			-- Not supported by the MinGW compiler

feature {NONE} -- Implementation


	internal_address_sockaddr: POINTER
			-- The internal pointer of `address'

	structure_size: INTEGER
			-- <Precursor>
		do
			Result := c_sizeof_adapter_addresses
		end

	factory:NET_INTERFACE_FACTORY_IMP
			-- The {NET_INTERFACE_FACTORY} is kept here to be certain that `Current' is not freed

feature {NONE} -- Externals

	frozen c_sizeof_adapter_addresses: INTEGER
			-- Size of an IP_ADAPTER_ADDRESSES C structure.
		external
			"C inline use <WinSock2.h>, <Iphlpapi.h>"
		alias
			"sizeof (IP_ADAPTER_ADDRESSES)"
		end

	frozen get_adapter_addresses_struct_friendlyname(a_item:POINTER):POINTER
			-- Extracting the name from `a_item'
		external
			"C inline use <WinSock2.h>, <Iphlpapi.h>"
		alias
			"((PIP_ADAPTER_ADDRESSES)$a_item)->FriendlyName"
		end


	frozen c_getnameinfo(a_sockaddr:POINTER; a_addrlen:INTEGER; a_host:POINTER; a_hostlen:INTEGER; a_serv:POINTER; a_servlen, a_flags:INTEGER):INTEGER
			-- Get the host name from `a_sockaddr'.
		external
			"C (const struct sockaddr *, socklen_t, char *, socklen_t, char *, socklen_t, int):int | <ws2tcpip.h>"
		alias
			"getnameinfo"
		end

	frozen c_sizeof_sockaddr_in: INTEGER
			-- Size of an sockaddr_in C structure.
		external
			"C inline use Winsock2.h"
		alias
			"sizeof (struct sockaddr_in)"
		end

	frozen c_sizeof_sockaddr_in6: INTEGER
			-- Size of an sockaddr_in6 C structure.
		external
			"C inline use Winsock2.h"
		alias
			"sizeof (struct sockaddr_in6)"
		end

end
