module main

import arrays
import os

fn generate() !(string, string) {
	print('プリセット名を入力してください: ')
	cursor_name_input := os.get_line()
	print('これからカーソルの名称が表示されるので、対応するカーソルファイルをドラッグ&ドロップし、Enterキーを押してください。該当するカーソルファイルが存在しない場合、そのままEnterキーを押してください。 [ENTERキーを押して続行]')
	os.get_line()
	print('通常の選択 (Arrow): ')
	arrow_path := os.get_line()
	print('ヘルプの選択 (Help): ')
	help_path := os.get_line()
	print('バックグラウンドで作業中 (AppStarting): ')
	appstarting_path := os.get_line()
	print('待ち状態 (Wait): ')
	wait_path := os.get_line()
	print('領域選択 (Crosshair): ')
	crosshair_path := os.get_line()
	print('テキスト選択 (IBeam): ')
	ibeam_path := os.get_line()
	print('手書き (NWPen): ')
	nwpen_path := os.get_line()
	print('利用不可 (No): ')
	no_path := os.get_line()
	print('上下に拡大/縮小 (SizeNS): ')
	sizens_path := os.get_line()
	print('左右に拡大/縮小 (SizeWE): ')
	sizewe_path := os.get_line()
	print('斜めに拡大/縮小 1 (SizeNWSE): ')
	sizenwse_path := os.get_line()
	print('斜めに拡大/縮小 2 (SizeNESW): ')
	sizenesw_path := os.get_line()
	print('移動 (SizeAll): ')
	sizeall_path := os.get_line()
	print('代替選択 (UpArrow): ')
	uparrow_path := os.get_line()
	print('リンクの選択 (Hand): ')
	hand_path := os.get_line()

	dirs := arrays.distinct([arrow_path, help_path, appstarting_path, wait_path, crosshair_path,
		ibeam_path, nwpen_path, no_path, sizens_path, sizewe_path, sizenwse_path, sizenesw_path,
		sizeall_path, uparrow_path, hand_path].filter(it.len > 0).map(os.dir(it)))
	toml := if dirs.len == 1 {
		path := os.dir(dirs[0])
		name := os.file_name(dirs[0])

		cursor_name := if cursor_name_input == name {
			''
		} else {
			cursor_name_input
		}

		arrow := os.file_name(arrow_path)
		help := os.file_name(help_path)
		appstarting := os.file_name(appstarting_path)
		wait := os.file_name(wait_path)
		crosshair := os.file_name(crosshair_path)
		ibeam := os.file_name(ibeam_path)
		nwpen := os.file_name(nwpen_path)
		no := os.file_name(no_path)
		sizens := os.file_name(sizens_path)
		sizewe := os.file_name(sizewe_path)
		sizenwse := os.file_name(sizenwse_path)
		sizenesw := os.file_name(sizenesw_path)
		sizeall := os.file_name(sizeall_path)
		uparrow := os.file_name(uparrow_path)
		hand := os.file_name(hand_path)

		$tmpl('preset_generator.txt')
	} else {
		path := ''
		name := ''
		cursor_name := cursor_name_input

		arrow := arrow_path
		help := help_path
		appstarting := appstarting_path
		wait := wait_path
		crosshair := crosshair_path
		ibeam := ibeam_path
		nwpen := nwpen_path
		no := no_path
		sizens := sizens_path
		sizewe := sizewe_path
		sizenwse := sizenwse_path
		sizenesw := sizenesw_path
		sizeall := sizeall_path
		uparrow := uparrow_path
		hand := hand_path

		$tmpl('preset_generator.txt')
	}

	return cursor_name_input, toml
}
