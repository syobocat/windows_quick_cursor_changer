module main

import os
import toml

const cursors = ['Arrow', 'Help', 'AppStarting', 'Wait', 'Crosshair', 'IBeam', 'NWPen', 'No',
	'SizeNS', 'SizeWE', 'SizeNWSE', 'SizeNESW', 'SizeAll', 'UpArrow', 'Hand']

fn main() {
	// 設定ファイル作成
	if os.args.len < 2 {
		print('設定ファイルが与えられませんでした。作成します。 [ENTERキーを押して続行]')
		os.get_line()
		cursor_name, toml_string := generate() or {
			eprintln('エラーが起きました！ ${err}')
			wait()
			exit(1)
		}
		if !os.exists('settings') {
			os.mkdir('settings') or {
				eprintln('設定ファイルを格納するフォルダの作成に失敗しました！ ${err}')
				wait()
				exit(1)
			}
		}
		mut f := os.create('settings/${cursor_name}.toml') or {
			eprintln('設定ファイルの作成に失敗しました！ ${err}')
			wait()
			exit(1)
		}
		f.write_string(toml_string) or {
			eprintln('設定ファイルへの書き込みに失敗しました！ ${err}')
			wait()
			exit(1)
		}
		f.close()
		println('設定ファイルが作成されました！')
		wait()
		exit(0)
	}

	settings_file := os.args[1]

	if !os.exists(settings_file) {
		eprintln('設定ファイル ${settings_file} は存在しないよ！')
		wait()
		exit(1)
	}

	settings := toml.parse_file(settings_file) or {
		eprintln('設定ファイル ${settings_file} がおかしいよ！')
		wait()
		exit(1)
	}

	// ファイル読み込み
	cursor_scheme := settings.value('scheme').default_to(1).u64()
	cursor_path := settings.value('path').default_to(r'C:\Windows\Cursors').string()
	cursor_dir := settings.value('name').default_to('').string()
	cursor_name := settings.value('cursor_name').default_to(cursor_dir).string()

	mut cursor_files := map[string]string{}
	for cursor in cursors {
		cursor_files[cursor] = settings.value(cursor.to_lower()).default_to('').string()
	}

	// レジストリ書き換え
	registry_key := open_registry(.hkey_current_user, r'Control Panel\Cursors', .key_write) or {
		eprintln(err)
		wait()
		exit(1)
	}
	registry_key.set_sz('', cursor_name) or {
		eprintln(err)
		wait()
		exit(1)
	}
	registry_key.set_dword('Scheme Source', u32(cursor_scheme)) or {
		eprintln(err)
		wait()
		exit(1)
	}
	for registry_name, cursor_file in cursor_files {
		if cursor_file == ':NULL' {
			// :NULLと指定するとレジストリに空文字を登録
			registry_key.set_sz(registry_name, '') or {
				eprintln(err)
				wait()
				exit(1)
			}
		} else {
			cursor := os.join_path(cursor_path, cursor_dir, cursor_file)
			if os.is_file(cursor) {
				registry_key.set_sz(registry_name, cursor) or {
					eprintln(err)
					wait()
					exit(1)
				}
			} else {
				eprintln('[注意!] カーソルファイル ${cursor} は存在しません！')
			}
		}
	}
	registry_key.close() or {
		eprintln(err)
		wait()
		exit(1)
	}

	// カーソルを更新
	update_cursor()

	println('完了しました！')
	wait()
}

fn wait() {
	print('[ENTERキーを押して終了]')
	os.get_line()
}
