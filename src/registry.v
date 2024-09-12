module main

import builtin.wchar

#include <windows.h>

enum KeyHandles as u32 {
	hkey_classes_root                = 0x80000000
	hkey_current_user                = 0x80000001
	hkey_local_machine               = 0x80000002
	hkey_users                       = 0x80000003
	hkey_performance_data            = 0x80000004
	hkey_current_config              = 0x80000005
	hkey_dyn_data                    = 0x80000006
	hkey_current_user_local_settings = 0x80000007
	hkey_performance_text            = 0x80000050
	hkey_performance_nlstext         = 0x80000060
}

enum RegAsm as u32 {
	key_query_value        = 0x0001
	key_set_value          = 0x0002
	key_create_sub_key     = 0x0004
	key_enumerate_sub_keys = 0x0008
	key_notify             = 0x0010
	key_create_link        = 0x0020
	key_read               = (0x00020000 | 0x0001 | 0x0008 | 0x0010) & (~0x00100000)
	key_write              = (0x00020000 | 0x0002 | 0x0004) & (~0x00100000)
	key_all_access         = (0x001f0000 | 0x0001 | 0x0002 | 0x0004 | 0x0008 | 0x0010 | 0x0020) & (~0x00100000)
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

fn C.RegOpenKeyExW(hKey voidptr, lpSubKey &wchar.Character, ulOptions u32, samDesired u32, phkResult &voidptr) i32

fn C.RegSetValueExW(hKey voidptr, lpValueName &wchar.Character, Reserved u32, dwType u32, const_lpData &u8, cbData u32) i32

fn set_registry_sz(key KeyHandles, subkey string, name string, value string) ! {
	handle := voidptr(u32(key))
	value_wchar := wchar.from_string('${value}\0')
	mut hkey := unsafe { nil }
	open_status := C.RegOpenKeyExW(handle, wchar.from_string(subkey), 0, u32(RegAsm.key_write),
		hkey)
	if open_status != 0 {
		return error('レジストリキーのオープンに失敗しました: コード${open_status}')
	}
	unsafe {
		set_status := C.RegSetValueExW(hkey, wchar.from_string(name), 0, u32(RegType.sz),
			value_wchar, wchar.length_in_bytes(value_wchar))
		if set_status != 0 {
			return error('レジストリキーの設定に失敗しました: コード${set_status}')
		}
	}
}
