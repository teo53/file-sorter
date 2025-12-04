@echo off
chcp 65001 >nul
title File Sorter - Rollback

echo ========================================
echo   File Restoration System
echo ========================================
echo.
echo This will restore files to their original locations.
echo.
echo Options:
echo [1] Rollback last 1 file
echo [2] Rollback last 5 files
echo [3] Rollback last 10 files
echo [4] Rollback ALL files
echo [5] Cancel
echo.
set /p choice="Select option (1-5): "

if "%choice%"=="1" goto rollback_1
if "%choice%"=="2" goto rollback_5
if "%choice%"=="3" goto rollback_10
if "%choice%"=="4" goto rollback_all
if "%choice%"=="5" goto cancel
goto invalid

:rollback_1
echo.
echo Restoring last 1 file...
cd /d "%~dp0src"
python -c "from rollback import FileRollback; r=FileRollback(); count=r.rollback_latest(1); print(f'\nRestored {count} file(s)')"
goto end

:rollback_5
echo.
echo Restoring last 5 files...
cd /d "%~dp0src"
python -c "from rollback import FileRollback; r=FileRollback(); count=r.rollback_latest(5); print(f'\nRestored {count} file(s)')"
goto end

:rollback_10
echo.
echo Restoring last 10 files...
cd /d "%~dp0src"
python -c "from rollback import FileRollback; r=FileRollback(); count=r.rollback_latest(10); print(f'\nRestored {count} file(s)')"
goto end

:rollback_all
echo.
echo WARNING: This will restore ALL moved files!
set /p confirm="Are you sure? (y/n): "
if /i "%confirm%"=="y" (
    cd /d "%~dp0src"
    python -c "from rollback import FileRollback; r=FileRollback(); files=r.list_rollbackable_files(); count=r.rollback_latest(len(files)); print(f'\nRestored {count} file(s)')"
)
goto end

:cancel
echo.
echo Cancelled.
goto end

:invalid
echo.
echo Invalid choice.
timeout /t 2 >nul
goto end

:end
echo.
echo ========================================
echo   Done!
echo ========================================
echo.
pause
