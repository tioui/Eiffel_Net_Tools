note
	description: "Internal implementation of the {NET_INTERFACE_FACTORY} for MinGW."
	author: "Louis Marchand"
	date: "Thu, 19 Apr 2018 18:10:33 +0000"
	revision: "0.1"

deferred class
	NET_INTERFACE_FACTORY_WIN_IMP

feature {NONE} -- Implementation

	get_netmask_value(a_address:POINTER;a_inet_address:INET_ADDRESS):detachable INET_ADDRESS
			-- This feature is not supported by the MinGW compiler.
		do
			Result := Void
		end

end
