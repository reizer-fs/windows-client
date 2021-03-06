@echo off
setlocal

for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%version%" == "6.1" (
REM REPLACING DLL TO MANAGE CUSTOM THEME
cd %~dp0
xcopy /C/H/R/S/Y Lib\* C:\Windows\System32\
REM ADDING WINX THEME FILES


robocopy Themes\ C:\Windows\Resources\Themes\ /E
robocopy Components\CPUZ "C:\Program Files (x86)\CPUZ" >nul 2>&1
robocopy Components\GPUZ "C:\Program Files (x86)\GPUZ" /NFL >nul 2>&1
robocopy Components\GPU_Caps "C:\Program Files (x86)\GPU_Caps" >nul 2>&1
robocopy Components\TaskManager "C:\Program Files (x86)\TaskManager" >nul 2>&1
robocopy Components\putty.exe "C:\Program Files (x86)\Putty\" >nul 2>&1
robocopy Components\MobaXterm "C:\Program Files (x86)\MobaXterm\" >nul 2>&1



REM ADD CONTEXT MENU OPENWITH NOTEPAD++
regedit.exe /S Registry\OpenWithNotepad.reg
regedit.exe /S Registry\ChangeSP.reg
call Components\OpenWithExt.cmd

REM DISABLE HIBERNATION
powercfg -h off

REM INSTALL DRIVER
RUNDLL32.EXE SETUPAPI.DLL,InstallHinfSection DefaultInstall 132 Drivers\NetGear\DriversWNA1000M.inf
RUNDLL32.EXE SETUPAPI.DLL,InstallHinfSection DefaultInstall 132 Drivers\TP-Link\netrtwlanu.inf

REM ADDED TO TASKBAR
cscript Scripts\PinItem.vbs /taskbar /item:"C:\Program Files (x86)\Putty\putty.exe"
cscript Scripts\PinItem.vbs /taskbar /item:"C:\Program Files (x86)\MobaXterm\MobaXterm_Personal_8.2.exe"
cscript Scripts\PinItem.vbs /taskbar /item:"C:\Program Files (x86)\GPUZ\GPU-Z.1.12.0.exe"
cscript Scripts\PinItem.vbs /taskbar /item:"C:\Program Files (x86)\GPU_Caps\GpuCapsViewer.exe"
cscript Scripts\PinItem.vbs /taskbar /item:"C:\Program Files (x86)\CPUZ\cpuz_x64.exe"

REM RUN INSTALL
"C:\Program Files (x86)\TaskManager\DBCTaskmanX64.exe"
START /WAIT Components\vcredist_x64.exe
START /WAIT Components\NET-45.exe
START /WAIT Components\ImageGlass.exe
START /WAIT Components\chrome_installer.exe
START /WAIT Components\SumatraPDF.exe
START /WAIT Components\7z920-x64.msi
START /WAIT Components\Clover_Setup.exe
START /WAIT Components\Notepad.exe
START /WAIT Components\ServicesRepair.exe
START /WAIT Components\UniversalThemePatcher-x64.exe
START /WAIT Components\CustomizerGod.exe
START /WAIT Components\Windows_Loader.exe
)

endlocal