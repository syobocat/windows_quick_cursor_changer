module main

import os
import toml

const registry_header = 'Windows Registry Editor Version 5.00'
const registry_path = r'HKEY_CURRENT_USER\Control Panel\Cursors'

const cursors = ['Arrow', 'Help', 'AppStarting', 'Wait', 'Crosshair', 'IBeam', 'NWPen', 'No',
	'SizeNS', 'SizeWE', 'SizeNWSE', 'SizeNESW', 'SizeAll', 'UpArrow', 'Hand']

fn main() {
	// バリデーション
	if os.args.len < 2 {
		println('設定ファイルを.exeファイルにドラッグ&ドロップしてね')
		print('[ENTERキーを押して終了]')
		os.get_line()
		exit(0)
	}

	settings_file := os.args[1]

	if !os.exists(settings_file) {
		eprintln('その設定ファイルは存在しないよ！')
		print('[ENTERキーを押して終了]')
		os.get_line()
		exit(1)
	}

	settings := toml.parse_file(settings_file) or {
		eprintln('設定ファイルがおかしいよ！')
		print('[ENTERキーを押して終了]')
		os.get_line()
		exit(1)
	}

	// ファイル読み込み
	cursor_path := settings.value('path').default_to(r'C:\Windows\Cursors').string()
	cursor_name := settings.value('name').default_to('').string()

	mut cursor_files := map[string]string{}
	for cursor in cursors {
		cursor_files[cursor] = settings.value(cursor.to_lower()).default_to('').string()
	}

	// レジストリファイル作成
	os.rm('クリックでカーソル適用.reg') or {}
	mut reg := os.create('クリックでカーソル適用.reg') or {
		eprintln('レジストリファイルの作成に失敗しました')
		os.get_line()
		exit(1)
	}

	reg.writeln(registry_header)!
	reg.writeln('')!
	reg.writeln('[${registry_path}]')!

	for registry_name, cursor_file in cursor_files {
		cursor := os.join_path(cursor_path, cursor_name, cursor_file)
		if os.exists(cursor) {
			reg.writeln('"${registry_name}"="${cursor}"')!
		} else {
			eprintln('[注意!] カーソルファイル ${cursor} は存在しません！')
		}
	}

	reg.close()

	println('完了しました。「クリックでカーソル適用.reg」ファイルを開くとカーソルが適用されます。')
	print('[ENTERキーを押して終了]')

	os.get_line()
}
