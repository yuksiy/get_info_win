@echo off

rem ==============================================================================
rem   機能
rem     システム設定一覧を取得する
rem   構文
rem     :USAGE 参照
rem
rem   Copyright (c) 2007-2017 Yukio Shiiya
rem
rem   This software is released under the MIT License.
rem   https://opensource.org/licenses/MIT
rem ==============================================================================

rem **********************************************************************
rem * 基本設定
rem **********************************************************************
rem 環境変数のローカライズ開始
setlocal

rem 遅延環境変数展開の有効化
verify other 2>nul
setlocal enabledelayedexpansion
if errorlevel 1 (
	echo -E Unable to enable delayedexpansion 1>&2
	exit /b 1
)

rem **********************************************************************
rem * 変数定義
rem **********************************************************************
rem ユーザ変数

rem システム環境 依存変数
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	set CYGWINROOT=%SystemDrive%\cygwin64
) else (
	set CYGWINROOT=%SystemDrive%\cygwin
)
set PATH=%PATH%;%CYGWINROOT%\bin

set CSCRIPT=%SystemRoot%\system32\cscript.exe //nologo
for /f "tokens=1" %%i in ('which_simple.bat wmi_ls.vbs') do set WMI_LS=%%i
for /f "tokens=1" %%i in ('which_simple.bat prog_ls.vbs') do set PROG_LS=%%i
for /f "tokens=1" %%i in ('which_simple.bat update_ls.vbs') do set UPDATE_LS=%%i
set POWERSHELL=powershell.exe
for /f "tokens=1" %%i in ('which_simple.bat package_ls.ps1') do set PACKAGE_LS=%%i
for /f "tokens=1" %%i in ('which_simple.bat hotfix_ls.ps1') do set HOTFIX_LS=%%i
for /f "tokens=1" %%i in ('which_simple.bat appxpackage_ls.ps1') do set APPXPACKAGE_LS=%%i
set QFECHECK=%SystemRoot%\system32\qfecheck.exe
for /f "tokens=1" %%i in ('which_simple.bat dp_list.bat') do set DP_LIST=%%i
for /f "tokens=1" %%i in ('which_simple.bat inetfw_netsh_main.bat') do set INETFW_NETSH_MAIN=%%i
for /f "tokens=1" %%i in ('which_simple.bat schtasks_main.bat') do set SCHTASKS_MAIN=%%i

rem プログラム内部変数

rem **********************************************************************
rem * サブルーチン定義
rem **********************************************************************
:def_subroutine
goto end_def_subroutine

:USAGE
	echo Usage:                         1>&2
	echo   get_config_list.bat DEST_DIR 1>&2
goto :EOF

:end_def_subroutine

rem **********************************************************************
rem * メインルーチン
rem **********************************************************************

rem 第1引数のチェック
if "%~1"=="" (
	echo -E Missing DEST_DIR argument 1>&2
	call :USAGE & exit /b 1
) else (
	set DEST_DIR=%~1
	rem 宛先ディレクトリのチェック
	if not exist !DEST_DIR!\nul (
		echo -E DEST_DIR not a directory -- "!DEST_DIR!" 1>&2
		call :USAGE & exit /b 1
	)
)

rem システム構成情報の取得
if not "%WMI_LS%"=="" (
	%CSCRIPT% "%WMI_LS%" Win32_Group               > "%DEST_DIR%\WMI_LS_Win32_Group.LOG"           2>&1
	%CSCRIPT% "%WMI_LS%" Win32_LoadOrderGroup      > "%DEST_DIR%\WMI_LS_Win32_LoadOrderGroup.LOG"  2>&1
	%CSCRIPT% "%WMI_LS%" Win32_Service             > "%DEST_DIR%\WMI_LS_Win32_Service.LOG"         2>&1
	%CSCRIPT% "%WMI_LS%" Win32_SystemAccount       > "%DEST_DIR%\WMI_LS_Win32_SystemAccount.LOG"   2>&1
	%CSCRIPT% "%WMI_LS%" Win32_SystemDriver        > "%DEST_DIR%\WMI_LS_Win32_SystemDriver.LOG"    2>&1
	%CSCRIPT% "%WMI_LS%" Win32_UserAccount         > "%DEST_DIR%\WMI_LS_Win32_UserAccount.LOG"     2>&1
)
if not "%PROG_LS%"=="" (
	%CSCRIPT% "%PROG_LS%"   | sort                 > "%DEST_DIR%\PROG_LS.LOG"                      2>&1
)
if not "%UPDATE_LS%"=="" (
	%CSCRIPT% "%UPDATE_LS%" | sort                 > "%DEST_DIR%\UPDATE_LS.LOG"                    2>&1
)
if not "%PACKAGE_LS%"=="" (
	%POWERSHELL% "%PACKAGE_LS%"                    > "%DEST_DIR%\PACKAGE_LS.LOG"                   2>&1
)
if not "%HOTFIX_LS%"=="" (
	%POWERSHELL% "%HOTFIX_LS%"                     > "%DEST_DIR%\HOTFIX_LS.LOG"                    2>&1
)
if not "%APPXPACKAGE_LS%"=="" (
	%POWERSHELL% "%APPXPACKAGE_LS%"                > "%DEST_DIR%\APPXPACKAGE_LS.LOG"               2>&1
)
if exist %QFECHECK% (
	%QFECHECK% /v                                  > "%DEST_DIR%\QFECHECK.LOG"                     2>&1
)
if exist "%CYGWINROOT%\bin\cygwin*.dll" (
	%CYGWINROOT%\bin\cygcheck.exe -c               > "%DEST_DIR%\CYGCHECK-C.LOG"                   2>&1
)
netsh dump                                         > "%DEST_DIR%\NET-DUMP.LOG"                     2>&1
ipconfig /all                                      > "%DEST_DIR%\IPCONFIG-ALL.LOG"                 2>&1
netstat -ano                                       > "%DEST_DIR%\NETSTAT-ANO.LOG"                  2>&1
netstat -rn                                        > "%DEST_DIR%\NETSTAT-RN.LOG"                   2>&1
tasklist /m   /fo table                            > "%DEST_DIR%\TASKLIST-M.LOG"                   2>&1
tasklist /svc /fo table                            > "%DEST_DIR%\TASKLIST-SVC.LOG"                 2>&1
tasklist /v   /fo table                            > "%DEST_DIR%\TASKLIST-V.LOG"                   2>&1
if exist %SystemRoot%\System32\bcdedit.exe (
	%SystemRoot%\System32\bcdedit.exe /v /enum ALL > "%DEST_DIR%\BCDEDIT-V-ENUM_ALL.LOG"           2>&1
	%SystemRoot%\System32\bcdedit.exe    /enum ALL > "%DEST_DIR%\BCDEDIT-ENUM_ALL.LOG"             2>&1
)
if exist "%ProgramFiles%\Support Tools\dmdiag.exe" (
	"%ProgramFiles%\Support Tools\dmdiag.exe" -v   > "%DEST_DIR%\DMDIAG-V.LOG"                     2>&1
)
if not "%DP_LIST%"=="" (
	for /f "tokens=2" %%i in ('%DP_LIST% disk 2^>^&1 ^| findstr /i /r /c:"\<Disk[ ]*[0-9]*[ ]*オンライン\>" /c:"\<ディスク[ ]*[0-9]*[ ]*オンライン\>"') do @(
		call %DP_LIST% partition %%i               > "%DEST_DIR%\DP_LIST-PARTITION-%%i.LOG"        2>&1
	)
)
if exist "%CYGWINROOT%\bin\cygwin*.dll" (
	df --sync -x iso9660 -x smbfs -T               > "%DEST_DIR%\DF--SYNC-X-ISO9660-X-SMBFS-T.LOG" 2>&1
	mount                                          > "%DEST_DIR%\MOUNT.LOG"                        2>&1
)
if exist "%SystemDrive%\apcupsd\bin\apcaccess.exe" (
	%SystemDrive%\apcupsd\bin\apcaccess.exe status > "%DEST_DIR%\APCACCESS-STATUS.LOG"             2>&1
	rem %SystemDrive%\apcupsd\bin\apcaccess.exe eprom  > "%DEST_DIR%\APCACCESS-EPROM.LOG"              2>&1
)
if not "%INETFW_NETSH_MAIN%"=="" (
	mkdir                                            "%DEST_DIR%\inetfw_netsh"
	call "%INETFW_NETSH_MAIN%"                       "%DEST_DIR%\inetfw_netsh"
) else (
	mkdir                                                                                                  "%DEST_DIR%\inetfw_netsh"
	netsh advfirewall export                                                                               "%DEST_DIR%\inetfw_netsh\netsh-advfirewall-export.wfw" > nul
	netsh advfirewall show allprofiles                    2>&1 | dos2unix | iconv -f CP932 -t UTF-8 2>&1 > "%DEST_DIR%\inetfw_netsh\netsh-advfirewall-show-allprofiles.ja.txt"
	netsh advfirewall firewall show rule name=all verbose 2>&1 | dos2unix | iconv -f CP932 -t UTF-8 2>&1 > "%DEST_DIR%\inetfw_netsh\netsh-advfirewall-firewall-show-rule.ja.txt"
)
if not "%SCHTASKS_MAIN%"=="" (
	call "%SCHTASKS_MAIN%"                           "%DEST_DIR%\schtasks-one"
) else (
	schtasks /query /xml one                              2>&1 | dos2unix | iconv -f CP932 -t UTF-8 2>&1 > "%DEST_DIR%\schtasks-one.xml"
)

