module main

import builtin.wchar

#include <windows.h>

type BYTE = u8
type DWORD = u32
type HKEY = voidptr
type LONG = i32
type LPCWSTR = &C.wchar_t
type REGSAM = u32

const read_control = u32(0x00020000)
const standard_rights_read = read_control
const standard_rights_write = read_control
const standard_rights_all = u32(0x001f0000)
const synchronize = u32(0x00100000)
const key_query_value = u32(0x0001)
const key_set_value = u32(0x0002)
const key_create_sub_key = u32(0x0004)
const key_enumerate_sub_keys = u32(0x0008)
const key_notify = u32(0x0010)
const key_create_link = u32(0x0020)
// const key_wow64_32key = u32(0x0200)
// const key_wow64_64key = u32(0x0100)
// const key_wow64_res = u32(0x0300)

const key_read = (standard_rights_read | key_query_value | key_enumerate_sub_keys | key_notify) & (~synchronize)
const key_write = (standard_rights_write | key_set_value | key_create_sub_key) & (~synchronize)
const key_execute = key_read & (~synchronize)
const key_all_access = (standard_rights_all | key_query_value | key_set_value | key_create_sub_key | key_enumerate_sub_keys | key_notify | key_create_link) & (~synchronize)

enum KeyHandles {
	hkey_classes_root
	hkey_current_user
	hkey_local_machine
	hkey_users
	hkey_performance_data
	hkey_current_config
	hkey_dyn_data
	hkey_current_user_local_settings
	hkey_performance_text
	hkey_performance_nlstext
}

enum RegAsm as u32 {
	key_query_value        = key_query_value
	key_set_value          = key_set_value
	key_create_sub_key     = key_create_sub_key
	key_enumerate_sub_keys = key_enumerate_sub_keys
	key_notify             = key_notify
	key_create_link        = key_create_link
	key_read               = key_read
	key_write              = key_write
	key_execute            = key_execute
	key_all_access         = key_all_access
}

enum RegType as u32 {
	@none                      = 0
	sz                         = 1
	expand_sz                  = 2
	binary                     = 3
	dword                      = 4
	dword_big_endian           = 5
	link                       = 6
	multi_sz                   = 7
	resource_list              = 8
	full_resource_descriptor   = 9
	resource_requirements_list = 10
	qword                      = 11
}

fn C.RegOpenKeyExW(hKey voidptr, lpSubKey &wchar.Character, ulOptions u32, samDesired u32, phkResult &voidptr) LONG

fn C.RegSetValueExW(hKey voidptr, lpValueName &wchar.Character, Reserved u32, dwType u32, const_lpData &u8, cbData u32) LONG

fn set_registry_sz(key KeyHandles, subkey string, name string, value string) {
	handle := match key {
		.hkey_classes_root { voidptr(0x80000000) }
		.hkey_current_user { voidptr(0x80000001) }
		.hkey_local_machine { voidptr(0x80000002) }
		.hkey_users { voidptr(0x80000003) }
		.hkey_performance_data { voidptr(0x80000004) }
		.hkey_current_config { voidptr(0x80000005) }
		.hkey_dyn_data { voidptr(0x80000006) }
		.hkey_current_user_local_settings { voidptr(0x80000007) }
		.hkey_performance_text { voidptr(0x80000050) }
		.hkey_performance_nlstext { voidptr(0x80000060) }
	}
	value_wchar := wchar.from_string('${value}\0')
	mut hkey := unsafe { nil }
	C.RegOpenKeyExW(handle, wchar.from_string(subkey), 0, u32(RegAsm.key_write), hkey)
	unsafe {
		C.RegSetValueExW(hkey, wchar.from_string(name), 0, u32(RegType.sz), value_wchar,
			wchar.length_in_bytes(value_wchar))
	}
}
