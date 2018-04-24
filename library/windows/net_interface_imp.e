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
		redefine
			out
		end
	MEMORY_STRUCTURE
		export
			{NONE} all
		redefine
			out
		end

feature {NONE} -- Initialization

	make(
				a_address_sockaddr, a_netmask_sockaddr, a_item:POINTER;
				a_factory:NET_INTERFACE_FACTORY_IMP 
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
			internal_netmask_sockaddr := a_netmask_sockaddr
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



	netmask: detachable INET_ADDRESS
			-- The IP address mask of `Current', if any
			-- Not supported with MinGW compiler.

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

feature {NONE} -- Implementation


	internal_address_sockaddr: POINTER
			-- The internal pointer of `address'

	internal_netmaks_sockaddr: POINTER
			-- The internal pointer of `netmask'

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

end
