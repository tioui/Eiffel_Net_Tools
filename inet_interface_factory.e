note
	description: "Summary description for {INET_INTERFACE_FACTORY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	INET_INTERFACE_FACTORY

inherit
	DISPOSABLE
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- Initialization of `Current'
		local
			l_item:POINTER
			l_error:INTEGER
		do
			has_error := False
			create l_item
			l_error := c_getifaddrs($l_item)
			if l_error /= 0 then
				error_number := c_errno
				has_error := True
			end
			has_error := l_error /= 0
			item := l_item
			create {LINKED_LIST[INET_INTERFACE_INFO]}interfaces.make
			if not has_error then
				from until l_item.is_default_pointer loop
					interfaces.extend (create {INET_INTERFACE_INFO}.make_by_ifaddrs(l_item, Current))
					l_item := get_ifaddrs_struct_ifa_next(l_item)
				end
			end
		end

feature -- Access

	interfaces:LIST[INET_INTERFACE_INFO]
			-- Every {INET_INTERFACE_INFO} on the local system

	has_error:BOOLEAN
			-- An error occured at the initialisation of `Current'

	error_number:INTEGER
			-- If `has_error', return the posix index of the error

	error_message:READABLE_STRING_GENERAL
			-- If `has_error', return the message representing the error
		local
			l_pointer:MANAGED_POINTER
			l_c_string:C_STRING
		do
			create l_pointer.make (255)
			c_strerror_r(error_number, l_pointer.item, 255)
			create l_c_string.make_shared_from_pointer (l_pointer.item)
			Result := l_c_string.string
		end

feature {NONE} -- Implentation

	item:POINTER
			-- The intenal representation of `Current'

	dispose
			-- <Precursor>
		do
			if not item.is_default_pointer then
				c_freeifaddrs(item)
			end
		end

feature {NONE} -- Externals

	frozen c_getifaddrs(a_ifap:POINTER):INTEGER
		external
			"C (struct ifaddrs **) : int | <ifaddrs.h>"
		alias
			"getifaddrs"
		end

	frozen c_strerror_r(a_errnum:INTEGER; a_buffer:POINTER; a_buffe_size:INTEGER)
		external
			"C (int, char *, size_t) | <string.h>"
		alias
			"strerror_r"
		end


	frozen c_errno:INTEGER
		external
			"C inline use <errno.h>"
		alias
			"errno"
		end

	frozen c_freeifaddrs(a_ifap:POINTER)
		external
			"C (struct ifaddrs *) | <ifaddrs.h>"
		alias
			"freeifaddrs"
		end

	frozen get_ifaddrs_struct_ifa_next(ifaddrs:POINTER):POINTER
			-- Extracting the next interface C representation from `ifaddrs'
		external
			"C [struct <ifaddrs.h>] (struct ifaddrs):char *"
		alias
			"ifa_next"
		end

end
