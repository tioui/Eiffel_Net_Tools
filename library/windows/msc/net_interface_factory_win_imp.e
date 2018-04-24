note
	description: "Internal implementation of the {NET_INTERFACE_FACTORY} for MSC."
	author: "Louis Marchand"
	date: "Thu, 19 Apr 2018 18:10:33 +0000"
	revision: "0.1"

deferred class
	NET_INTERFACE_FACTORY_WIN_IMP

feature {NONE} -- Implementation

	get_netmask_value(a_address:POINTER;a_inet_address:INET_ADDRESS):detachable INET_ADDRESS
			-- Get the netmask of `a_address' and `a_inet_address' if any.
		local
			l_lenght:NATURAL_8
			l_factory:INET_ADDRESS_FACTORY
			l_netmask_array:detachable ARRAY[NATURAL_8]
		do
			create l_factory
			l_lenght := get_adapter_unicast_address_struct_onlinkprefixlength(a_address)
			if attached {INET4_ADDRESS} a_inet_address then
				l_netmask_array := lenght_to_address(l_lenght, {INET4_ADDRESS}.inaddrsz)
			elseif attached {INET6_ADDRESS} a_inet_address then
				l_netmask_array := lenght_to_address(l_lenght, {INET6_ADDRESS}.inaddrsz)
			else
				l_netmask_array := Void
			end
			if attached l_netmask_array as la_array then
				Result := l_factory.create_from_address (la_array)
			else
				Result := Void
			end
		end

	lenght_to_address(a_lenght:NATURAL_8; a_count:INTEGER):ARRAY[NATURAL_8]
			-- Transform a IP `a_lenght' prefix to an address array
		local
			l_index1, l_index2:INTEGER
			l_lenght, l_mask:NATURAL_8
		do
			l_lenght := a_lenght
			create Result.make_filled (0, 1, a_count)
			from
				l_index1 := 1
			until
				l_index1 > a_count
			loop
				l_mask := 0
				from
					l_index2 := 1
				until
					l_index2 > 8
				loop
					l_mask := l_mask.bit_shift_left (1)
					if l_lenght > 0 then
						l_mask := l_mask.bit_or (1)
						l_lenght := l_lenght - 1
					end
					l_index2 := l_index2 + 1
				end
				Result.put (l_mask, l_index1)
				l_index1 := l_index1 + 1
			end
		ensure
			Size_Valid: Result.count = {INET4_ADDRESS}.inaddrsz or Result.count = {INET6_ADDRESS}.inaddrsz
		end


feature {NONE} -- Externals

	frozen get_adapter_unicast_address_struct_onlinkprefixlength(a_item:POINTER):NATURAL_8
			-- Extracting the prefix lenght from `a_item'
		external
			"C inline use <WinSock2.h>, <Iphlpapi.h>"
		alias
			"((PIP_ADAPTER_UNICAST_ADDRESS)$a_item)->OnLinkPrefixLength"
		end

end
