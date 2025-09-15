# get_info_win

## 概要

システム情報の取得 (Windows)

## 使用方法

* 以下のコマンドはすべて「管理者として実行」した「コマンド プロンプト」から実行する必要があります。

### get_config_list.bat

システム設定一覧を出力先ディレクトリ(DEST_DIR)配下に取得します。

    get_config_list.bat DEST_DIR

### その他

* 上記で紹介したツールの詳細については、各ファイルのヘッダー部分を参照してください。

## 動作環境

OS:

* Cygwin

依存パッケージ または 依存コマンド:

* make (インストール目的のみ)
* dos2unix
* [which_simple_win](https://github.com/yuksiy/which_simple_win)

Optional

* [dp_tools](https://github.com/yuksiy/dp_tools)
* [inetfw_tools](https://github.com/yuksiy/inetfw_tools)
* [package_ls](https://github.com/yuksiy/package_ls)
* [schtasks_tools](https://github.com/yuksiy/schtasks_tools)
* [winget](https://docs.microsoft.com/en-us/windows/package-manager/winget/)
* [wmi_ls](https://github.com/yuksiy/wmi_ls)

## インストール

ソースからインストールする場合:

    (Cygwin の場合)
    # make install

fil_pkg.plを使用してインストールする場合:

[fil_pkg.pl](https://github.com/yuksiy/fil_tools_pl/blob/master/README.md#fil_pkgpl) を参照してください。

## インストール後の設定

環境変数「PATH」にインストール先ディレクトリを追加してください。

## 最新版の入手先

<https://github.com/yuksiy/get_info_win>

## License

MIT License. See [LICENSE](https://github.com/yuksiy/get_info_win/blob/master/LICENSE) file.

## Copyright

Copyright (c) 2007-2025 Yukio Shiiya
