@echo off
REM Script to update MSYS2 packages and fix DLL dependency issues
echo =====================================================
echo MSYS2 Package Update Script
echo =====================================================
echo.
echo This script will update your MSYS2 packages to fix
echo the "clock_gettime64" DLL entry point error.
echo.
echo Please ensure MSYS2 is installed at C:\msys64
echo.
pause

echo.
echo Step 1: Updating MSYS2 core packages...
echo =====================================================
C:\msys64\usr\bin\bash.exe -lc "pacman -Syu --noconfirm"

echo.
echo Step 2: Updating MinGW packages...
echo =====================================================
C:\msys64\usr\bin\bash.exe -lc "pacman -Syu --noconfirm"

echo.
echo Step 3: Updating development packages...
echo =====================================================
C:\msys64\usr\bin\bash.exe -lc "pacman -S --noconfirm mingw-w64-x86_64-libmicrohttpd mingw-w64-x86_64-json-c mingw-w64-x86_64-gcc mingw-w64-x86_64-gnutls"

echo.
echo Step 4: Cleaning and rebuilding the application...
echo =====================================================
cd /d "%~dp0"
C:\msys64\usr\bin\bash.exe -lc "cd '%CD:\=/%' && make clean && make"

echo.
echo =====================================================
echo Update complete!
echo =====================================================
echo.
echo Your C backend should now run without DLL errors.
echo Try running: book-api.exe
echo.
pause
