note
	description: "[
					Used to access every {NET_INTERFACE} of the local host.
					Windows version.
				]"
	author: "Louis Marchand"
	date: "Thu, 19 Apr 2018 18:10:33 +0000"
	revision: "0.1"

class
	NET_INTERFACE_FACTORY

inherit
	NET_INTERFACE_FACTORY_IMP
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- Initialization of `Current'
		local
			l_tries:INTEGER
			l_null:POINTER
			l_item:MANAGED_POINTER
			l_retried, l_success:BOOLEAN
			l_buffer_size:NATURAL_32
			l_current_item:POINTER
		do
			has_error := False
			create {LINKED_LIST[NET_INTERFACE]}internal_interfaces.make
			l_retried := False
			l_buffer_size := 15000
			create l_null
			create item.make (1)
			from
				l_tries := 0
				l_success := False
			until
				l_success or l_tries > 3
			loop
				create l_item.make (l_buffer_size.to_integer_32)
				internal_error_number := c_getadaptersaddresses (c_af_unspec, 0, l_null, l_item.item, $l_buffer_size)
				if internal_error_number = c_error_success then
					l_success := True
					item := l_item
					initialize_interfaces
				end
				l_tries := l_tries + 1
			end
			has_error := not l_success
		end

	initialize_interfaces
			-- Initialize the `interfaces'
		require
			No_Error: not has_error
		local
			l_current_item:POINTER
		do
			l_current_item := item.item
			from until l_current_item.is_default_pointer loop
				internal_interfaces.extend (create {NET_INTERFACE}.make_by_adapter_addresses (
										l_current_item, Current, Void, Void))
				process_unicast_address(l_current_item)
				l_current_item := get_adapter_addresses_struct_next(l_current_item)

			end
		end

	process_unicast_address(a_address:POINTER)
			-- Process an internal C IP_ADAPTER_UNICAST_ADDRESS pointer by `a_address'
		local
			l_address, l_socket_address, l_sockaddr:POINTER
			l_factory:INET_ADDRESS_FACTORY
			l_inet_address, l_inet_netmask:detachable INET_ADDRESS
		do
			create l_factory
			from
				l_address := get_adapter_addresses_struct_firstunicastaddress(a_address)
			until
				l_address.is_default_pointer
			loop
				l_socket_address := get_adapter_unicast_address_struct_address(l_address)
				if not l_socket_address.is_default_pointer then
					l_sockaddr := get_socket_address_struct_lpsockaddr(l_socket_address)
					if not l_sockaddr.is_default_pointer then
						l_inet_address := l_factory.create_from_sockaddr (l_sockaddr)
						if attached l_inet_address as la_inet_address then
							l_inet_netmask := get_netmask_value(l_address, la_inet_address)
							internal_interfaces.extend (create {NET_INTERFACE}.make_by_adapter_addresses (
										a_address, Current, la_inet_address, l_inet_netmask))
						end
					end
				end
				l_address := get_adapter_unicast_address_struct_next(l_address)
			end
		end

feature -- Access

	interfaces:LIST[NET_INTERFACE]
			-- Every interfaces of the system.
			-- The INET interfaces (those that have an ip address)
			-- are showed multiple time (on for the raw packet interface,
			-- an other for the IPv4 interface and another for the IPv6 interface)
		do
			create {ARRAYED_LIST[NET_INTERFACE]}Result.make (internal_interfaces.count)
			Result.append (internal_interfaces)
		end

	inet_interfaces:LIST[NET_INTERFACE]
			-- Every interfaces that have an ip address (IPv4 or IPv6)
		do
			create {LINKED_LIST[NET_INTERFACE]}Result.make
			across internal_interfaces as la_interfaces loop
				if attached la_interfaces.item.address then
					Result.extend (la_interfaces.item)
				end
			end
		end

	inet_interfaces_except_loopback_autoassigned:LIST[NET_INTERFACE]
			-- Interfaces that have an ip address (IPv4 or IPv6)
			-- excluding interfaces with auto-assigned IP or loopback
		do
			create {LINKED_LIST[NET_INTERFACE]}Result.make
			across internal_interfaces as la_interfaces loop
				if attached la_interfaces.item.address as la_address then
					if not la_address.is_loopback_address and not la_address.is_link_local_address then
						Result.extend (la_interfaces.item)
					end
				end
			end
		end

	inet4_interfaces:LIST[NET_INTERFACE]
			-- Every interfaces that have an IPv4 address
		do
			create {LINKED_LIST[NET_INTERFACE]}Result.make
			across internal_interfaces as la_interfaces loop
				if attached {INET4_ADDRESS} la_interfaces.item.address then
					Result.extend (la_interfaces.item)
				end
			end
		end

	inet4_interfaces_except_loopback_autoassigned:LIST[NET_INTERFACE]
			-- Interfaces that have an IPv4 address
			-- excluding interfaces with auto-assigned IP or loopback
		do
			create {LINKED_LIST[NET_INTERFACE]}Result.make
			across internal_interfaces as la_interfaces loop
				if attached {INET4_ADDRESS} la_interfaces.item.address as la_address then
					if not la_address.is_loopback_address and not la_address.is_link_local_address then
						Result.extend (la_interfaces.item)
					end
				end
			end
		end

	inet6_interfaces:LIST[NET_INTERFACE]
			-- Every interfaces that have an IPv6 address
		do
			create {LINKED_LIST[NET_INTERFACE]}Result.make
			across internal_interfaces as la_interfaces loop
				if attached {INET6_ADDRESS} la_interfaces.item.address then
					Result.extend (la_interfaces.item)
				end
			end
		end

	inet6_interfaces_except_loopback_autoassigned:LIST[NET_INTERFACE]
			-- Interfaces that have an IPv6 address
			-- excluding interfaces with auto-assigned IP or loopback
		do
			create {LINKED_LIST[NET_INTERFACE]}Result.make
			across internal_interfaces as la_interfaces loop
				if attached {INET6_ADDRESS} la_interfaces.item.address as la_address then
					if not la_address.is_loopback_address and not la_address.is_link_local_address then
						Result.extend (la_interfaces.item)
					end
				end
			end
		end

	has_error:BOOLEAN
			-- An error occured at the initialisation of `Current'

	error_number:INTEGER
			-- If `has_error', return the index of the error
		do
			Result := internal_error_number.to_integer_32
		end

	error_message:READABLE_STRING_GENERAL
			-- If `has_error', return the message representing the error
		do
			if internal_error_number = c_error_success then
				Result := "No Error"
			elseif internal_error_number = c_error_buffer_overflow then
				Result := "The buffer size is too small"
			elseif internal_error_number = c_error_address_not_associated then
				Result := "An address has not yet been associated with the network endpoint"
			elseif internal_error_number = c_error_invalid_parameter then
				Result := "One of the parameters is invalid"
			elseif internal_error_number = c_error_not_enough_memory then
				Result := "Insufficient memory resources are available to complete the operation"
			elseif internal_error_number = c_error_no_data then
				Result := "No addresses were found for the requested parameters"
			else
				Result := "Unmanaged error"
			end
		end

feature {NONE} -- Implentation

	internal_interfaces:LIST[NET_INTERFACE]
			-- Every {NET_INTERFACE} on the local system

	internal_error_number:NATURAL_32
			-- Internal representation of `error_number'

	item:MANAGED_POINTER
			-- The intenal representation of `Current'


feature {NONE} -- Externals

	frozen c_getadaptersaddresses(
						a_amily, a_flags:NATURAL_32;
						a_reserved, a_adapteraddresses, a_sizepointer:POINTER
					):NATURAL_32
			-- get host adapter addresses
		external
			"C signature (ULONG, ULONG, PVOID, PIP_ADAPTER_ADDRESSES, PULONG) : ULONG use <Winsock2.h>, <Iphlpapi.h>"
		alias
			"GetAdaptersAddresses"
		end

	frozen get_adapter_addresses_struct_next(a_item:POINTER):POINTER
			-- Extracting the next interface C representation from `a_item'
		external
			"C inline use <Winsock2.h>, <Iphlpapi.h>"
		alias
			"((PIP_ADAPTER_ADDRESSES)$a_item)->Next"
		end

	frozen c_af_unspec:NATURAL_32
			-- Flags to return both IPv4 and IPv6 addresses associated with adapters
		external
			"C inline use <Winsock2.h>, <Iphlpapi.h>"
		alias
			"AF_UNSPEC"
		end

	frozen c_error_buffer_overflow:NATURAL_32
			-- Error index indicating that the buffer size is too small
		external
			"C inline use <Winsock2.h>, <Iphlpapi.h>"
		alias
			"ERROR_BUFFER_OVERFLOW"
		end

	frozen c_error_success:NATURAL_32
			-- Error index indicating no error
		external
			"C inline use <Winsock2.h>, <Iphlpapi.h>"
		alias
			"ERROR_SUCCESS"
		end

	frozen c_error_address_not_associated:NATURAL_32
			-- Error index indicating that an address has not yet
			-- been associated with the network endpoint.
		external
			"C inline use <Winsock2.h>, <Iphlpapi.h>"
		alias
			"ERROR_ADDRESS_NOT_ASSOCIATED"
		end

	frozen c_error_invalid_parameter:NATURAL_32
			-- Error index indicating that one of the parameters is invalid.
		external
			"C inline use <Winsock2.h>, <Iphlpapi.h>"
		alias
			"ERROR_INVALID_PARAMETER"
		end

	frozen c_error_not_enough_memory:NATURAL_32
			-- Error index indicating that insufficient memory resources
			-- are available to complete the operation.
		external
			"C inline use <Winsock2.h>, <Iphlpapi.h>"
		alias
			"ERROR_NOT_ENOUGH_MEMORY"
		end

	frozen c_error_no_data:NATURAL_32
			-- Error index indicating that no addresses were
			-- found for the requested parameters.
		external
			"C inline use <Winsock2.h>, <Iphlpapi.h>"
		alias
			"ERROR_NO_DATA"
		end


	frozen get_adapter_addresses_struct_firstunicastaddress(a_item:POINTER):POINTER
			-- Extracting the first address from `a_item'
		external
			"C inline use <WinSock2.h>, <Iphlpapi.h>"
		alias
			"((PIP_ADAPTER_ADDRESSES)$a_item)->FirstUnicastAddress"
		end

	frozen get_adapter_unicast_address_struct_next(a_item:POINTER):POINTER
			-- Extracting the next address from `a_item'
		external
			"C inline use <WinSock2.h>, <Iphlpapi.h>"
		alias
			"((PIP_ADAPTER_UNICAST_ADDRESS)$a_item)->Next"
		end

	frozen get_adapter_unicast_address_struct_address(a_item:POINTER):POINTER
			-- Extracting the socket address from `a_item'
		external
			"C inline use <WinSock2.h>, <Iphlpapi.h>"
		alias
			"&(((PIP_ADAPTER_UNICAST_ADDRESS)$a_item)->Address)"
		end

	frozen get_socket_address_struct_lpsockaddr(a_item:POINTER):POINTER
			-- Extracting the SOCKADDR from `a_item'
		external
			"C inline use <WinSock2.h>, <Iphlpapi.h>"
		alias
			"((PSOCKET_ADDRESS)$a_item)->lpSockaddr"
		end


end
