module main

#include <windows.h>

const spi_setcursors = 0x0057
const spif_updateinifile = 0x0001
const spif_sendchange = 0x0002

fn C.SystemParametersInfoW(uiAction u32, uiParam u32, pvParam voidptr, fWinIni u32) int

fn update_cursor() ! {
	code := C.SystemParametersInfoW(spi_setcursors, 0, unsafe { nil }, spif_updateinifile | spif_sendchange)
	if code == 0 {
		return error('カーソルの更新に失敗しました')
	}
}
