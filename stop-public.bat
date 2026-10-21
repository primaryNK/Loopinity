@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Loopinity - Stop Public Server

echo.
echo ============================================================
echo   Loopinity Public Server - STOP
echo ============================================================
echo.

where docker >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Docker was not found.
  goto :failed
)

docker info >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Docker Desktop is not running.
  echo If Docker Desktop is already closed, the website is no longer public.
  goto :failed
)

echo [1/2] Stopping and removing the Cloudflare Tunnel...
docker rm -f loopinity-tunnel >nul 2>&1
if errorlevel 1 (
  echo       No named Loopinity Tunnel is running.
) else (
  echo       Tunnel stopped.
)

echo [2/2] Stopping the Loopinity web server...
docker compose down --remove-orphans
if errorlevel 1 (
  echo [ERROR] Could not stop the web server completely.
  goto :failed
)

echo.
echo ============================================================
echo   LOOPINITY IS NOW OFFLINE
echo   The previous trycloudflare.com URL is no longer reachable.
echo ============================================================
echo.
pause
exit /b 0

:failed
echo.
echo Shutdown encountered a problem. Review the message above.
echo.
pause
exit /b 1
