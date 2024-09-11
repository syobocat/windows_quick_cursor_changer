module main

import encoding.binary
import encoding.utf8

// 文字列をUTF-16LEに変換
fn to_utf16le(s string) []u8 {
	mut utf16 := []u8{}
	for i in 0 .. utf8.len(s) {
		index := u16(utf8.get_uchar('${utf8.raw_index(s, i)}', 0))
		println('${utf8.raw_index(s, i)}のコードポイントは${index}=${index.hex()}')
		if index < 0x10000 {
			utf16 << binary.little_endian_get_u16(index)
		} else {
			modified_index := index - 0x10000
			hi_surrogate := 0xD800 | (modified_index >> 10)
			lo_surrogate := 0xDC00 | (modified_index & 1023)
			utf16 << binary.little_endian_get_u16(hi_surrogate)
			utf16 << binary.little_endian_get_u16(lo_surrogate)
		}
	}

	return utf16
}
