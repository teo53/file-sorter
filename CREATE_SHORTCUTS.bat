@echo off
chcp 65001 >nul
echo ========================================
echo   Creating Desktop Shortcuts...
echo ========================================
echo.

set DESKTOP=%USERPROFILE%\Desktop
set SOURCE=%~dp0

echo [1/3] Creating 'File Sorter' shortcut...
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%DESKTOP%\File Sorter.lnk');$s.TargetPath='%SOURCE%AUTO_SORT.bat';$s.IconLocation='shell32.dll,166';$s.WorkingDirectory='%SOURCE%';$s.Save()"

echo [2/3] Creating 'Dashboard' shortcut...
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%DESKTOP%\Dashboard.lnk');$s.TargetPath='%SOURCE%DASHBOARD.bat';$s.IconLocation='shell32.dll,14';$s.WorkingDirectory='%SOURCE%';$s.Save()"

echo [3/3] Creating 'Rollback' shortcut...
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%DESKTOP%\Rollback.lnk');$s.TargetPath='%SOURCE%ROLLBACK.bat';$s.IconLocation='shell32.dll,238';$s.WorkingDirectory='%SOURCE%';$s.Save()"

echo.
echo ========================================
echo   Success!
echo ========================================
echo.
echo 3 shortcuts created on Desktop:
echo   1. File Sorter.lnk - Auto organize files
echo   2. Dashboard.lnk - Monitor and manage
echo   3. Rollback.lnk - Restore files
echo.
echo Now double-click these shortcuts on your Desktop!
echo.
pause
