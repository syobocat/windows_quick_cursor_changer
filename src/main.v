module main

import os
import toml

const cursors = ['Arrow', 'Help', 'AppStarting', 'Wait', 'Crosshair', 'IBeam', 'NWPen', 'No',
	'SizeNS', 'SizeWE', 'SizeNWSE', 'SizeNESW', 'SizeAll', 'UpArrow', 'Hand']

fn main() {
	// バリデーション
	if os.args.len < 2 {
		graceful_exit('設定ファイルを.exeファイルにドラッグ&ドロップしてね')
	}

	settings_file := os.args[1]

	if !os.exists(settings_file) {
		something_happened('設定ファイル ${settings_file} は存在しないよ！')
	}

	settings := toml.parse_file(settings_file) or {
		something_happened('設定ファイル ${settings_file} がおかしいよ！')
	}

	// ファイル読み込み
	cursor_path := settings.value('path').default_to(r'C:\Windows\Cursors').string()
	cursor_name := settings.value('name').default_to('').string()

	mut cursor_files := map[string]string{}
	for cursor in cursors {
		cursor_files[cursor] = settings.value(cursor.to_lower()).default_to('').string()
	}

	// レジストリ書き換え
	registry_key := open_registry(.hkey_current_user, r'Control Panel\Cursors', .key_write) or {
		something_happened('${err}')
	}
	registry_key.set_sz('', cursor_name) or { something_happened('${err}') }
	registry_key.set_dword('Scheme Source', 1) or { something_happened('${err}') }
	for registry_name, cursor_file in cursor_files {
		cursor := os.join_path(cursor_path, cursor_name, cursor_file)
		if os.is_file(cursor) {
			registry_key.set_sz(registry_name, cursor) or { something_happened('${err}') }
		} else {
			eprintln('[注意!] カーソルファイル ${cursor} は存在しません！')
		}
	}
	registry_key.close() or { something_happened('${err}') }

	// カーソルを更新
	update_cursor() or { something_happened('${err}') }

	graceful_exit('完了しました！')
}

@[noreturn]
fn something_happened(message string) {
	eprintln(message)
	print('[ENTERキーを押して終了]')
	os.get_line()
	exit(1)
}

@[noreturn]
fn graceful_exit(message string) {
	println(message)
	print('[ENTERキーを押して終了]')
	os.get_line()
	exit(0)
}
