@echo off

rem Check If User Has Admin Privileges
:CheckAdminPrivileges
timeout /t 1 /nobreak > NUL
openfiles > NUL 2>&1
if %errorlevel%==0 (
    echo Running..
) else (
    echo You must run me as an Administrator. Exiting..
    echo.
    echo Right-click on me and select ^'Run as Administrator^' and try again.
    echo.
    echo Press any key to exit..
    pause > NUL
    exit
)

rem Function to clean Scoop cache
:CleanScoopCache
echo Cleaning Scoop cache...
scoop cache rm -f * 2>&1 | findstr /V "Warning: Cannot verify hash"
if %errorlevel% NEQ 0 (
    echo Error: Failed to clean Scoop cache.
    pause > NUL
    exit /B 1
) else (
    echo Scoop cache cleaned successfully.
)

rem Function to clean Scoop apps
:CleanScoopApps
echo Cleaning Scoop apps...
scoop cleanup * 2>&1 | findstr /V "Nothing to do"
if %errorlevel% NEQ 0 (
    echo Error: Failed to clean Scoop apps.
    pause > NUL
    exit /B 1
) else (
    echo Scoop apps cleaned successfully.
)

rem Function to clean Conda cache
:CleanCondaCache
echo Cleaning Conda cache...
conda clean --all --yes | findstr /V "to remove"
echo Conda cache cleaned successfully.

rem Function to clean old Windows Update files
:CleanWindowsUpdate
echo Cleaning old Windows Update files...
cleanmgr /sagerun:1
echo Old Windows Update files cleaned successfully.

rem Function to clear Event Viewer logs
:ClearEventViewerLogs
echo Clearing Event Viewer logs...
for /F "tokens=*" %%G in ('wevtutil.exe el') do (wevtutil.exe cl "%%G")
echo Event Viewer logs cleared successfully.

rem Function to disable Prefetch
:DisablePrefetch
echo Disabling Prefetch...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f

rem Function to clean Windows Error Reporting files
:CleanErrorReporting
echo Cleaning Windows Error Reporting files...
del /s /f /q %WinDir%\System32\winevt\Logs\*.*
echo Windows Error Reporting files cleaned successfully.

rem Function to clean thumbnail cache
:CleanThumbnailCache
echo Cleaning thumbnail cache...
del /s /f /q %LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db
echo Thumbnail cache cleaned successfully.

rem Function to empty Recycle Bin
:EmptyRecycleBin
echo Emptying Recycle Bin...
rd /s /q %SystemDrive%\$Recycle.Bin
echo Recycle Bin emptied successfully.

rem Function to delete Temporary Files and Folders
:CleanTemporaryFiles
echo Cleaning temporary files...
del /s /f /q %WinDir%\Temp\*.*
del /s /f /q %WinDir%\Prefetch\*.*
del /s /f /q %Temp%\*.*
del /s /f /q %AppData%\Temp\*.*
del /s /f /q %HomePath%\AppData\LocalLow\Temp\*.*

rd /s /q %WinDir%\Temp
rd /s /q %WinDir%\Prefetch
rd /s /q %Temp%
rd /s /q %AppData%\Temp
rd /s /q %HomePath%\AppData\LocalLow\Temp

echo.
echo Cleanup Done! You can exit by pressing any key.
echo.

pause > NUL
exit
