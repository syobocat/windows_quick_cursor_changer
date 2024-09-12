module main

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

type Key = voidptr

fn C.RegOpenKeyExW(hKey voidptr, lpSubKey &u16, ulOptions u32, samDesired u32, phkResult &voidptr) i32
fn C.RegCloseKey(hKey voidptr) i32

fn C.RegSetValueExW(hKey voidptr, lpValueName &u16, Reserved u32, dwType u32, const_lpData &u16, cbData u32) i32

fn open_registry(key KeyHandles, subkey string) !Key {
	mut hkey := unsafe { nil }
	status := C.RegOpenKeyExW(u32(key), subkey.to_wide(), 0, u32(RegAsm.key_write), hkey)
	if status != 0 {
		return error('レジストリキーのオープンに失敗しました: コード${status}')
	}

	return hkey
}

fn (key Key) set_sz(name string, value string) ! {
	value_u16 := '${value}\0'.to_wide()
	status := C.RegSetValueExW(key, name.to_wide(), 0, u32(RegType.sz), value_u16, sizeof(value_u16))
	if status != 0 {
		return error('レジストリキーの設定に失敗しました: コード${status}')
	}
}

fn (key Key) close() ! {
	status := C.RegCloseKey(key)
	if status != 0 {
		return error('レジストリキーのクローズに失敗しました: コード${status}')
	}
}
