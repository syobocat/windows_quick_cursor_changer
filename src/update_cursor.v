module main

#include <windows.h>

const spi_setcursors = 0x0057
const spif_updateinifile = 0x01
const spif_sendchange = 0x02

fn C.SystemParametersInfoW(uiAction u32, uiParam u32, pvParam voidptr, fWinIni u32) bool

fn update_cursor() ! {
	if !C.SystemParametersInfoW(spi_setcursors, 0, unsafe { nil }, spif_updateinifile | spif_sendchange) {
		return error('カーソルの更新に失敗しました')
	}
}
