module main

import os
import toml

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
		eprintln('設定ファイル ${settings_file} は存在しないよ！')
		print('[ENTERキーを押して終了]')
		os.get_line()
		exit(1)
	}

	settings := toml.parse_file(settings_file) or {
		eprintln('設定ファイル ${settings_file} がおかしいよ！')
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

	for registry_name, cursor_file in cursor_files {
		cursor := os.join_path(cursor_path, cursor_name, cursor_file).replace(r'\', r'\\')
		set_registry_sz(.hkey_current_user, r'Control Panel\Cursors', registry_name, cursor)
	}

	println('完了しました。再起動や再ログインをするとカーソルが適用されます。')
	print('[ENTERキーを押して終了]')

	os.get_line()
}
