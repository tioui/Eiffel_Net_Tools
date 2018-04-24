note
	description: "[
					Used to access every {NET_INTERFACE} of the local host.
				]"
	author: "Louis Marchand"
	date: "Thu, 19 Apr 2018 18:10:33 +0000"
	revision: "0.1"

class
	NET_INTERFACE_FACTORY

inherit
	NET_INTERFACE_FACTORY_IMP

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

end
