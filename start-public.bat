@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title Loopinity - Public Server

echo.
echo ============================================================
echo   Loopinity Public Server - START
echo ============================================================
echo.

where docker >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Docker was not found.
  echo Install and start Docker Desktop, then try again.
  goto :failed
)

docker info >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Docker Desktop is not running.
  echo Start Docker Desktop and wait for the engine, then try again.
  goto :failed
)

echo [1/3] Building and starting the Loopinity web server...
rem Remove the legacy fixed-name container used by older project versions.
docker inspect loopinity-web >nul 2>&1
if not errorlevel 1 (
  echo       Removing a legacy Loopinity container...
  docker rm -f loopinity-web >nul 2>&1
  if errorlevel 1 (
    echo [ERROR] Could not remove the legacy loopinity-web container.
    goto :failed
  )
)

docker compose up --build -d
if errorlevel 1 (
  echo [ERROR] Could not start the web server.
  goto :failed
)

echo [2/3] Waiting for the web server health check...
set "WEB_CONTAINER="
for /F "delims=" %%C in ('docker compose ps -q web 2^>nul') do set "WEB_CONTAINER=%%C"
if not defined WEB_CONTAINER (
  echo [ERROR] Could not find the web container created by Compose.
  goto :failed
)

set "WEB_STATUS="
for /L %%I in (1,1,40) do (
  for /F "delims=" %%S in ('docker inspect --format "{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}" !WEB_CONTAINER! 2^>nul') do set "WEB_STATUS=%%S"
  if /I "!WEB_STATUS!"=="healthy" goto :web_ready
  timeout /t 1 /nobreak >nul
)

echo [ERROR] The web server did not become healthy in time.
docker compose logs --tail 30 web
goto :failed

:web_ready
echo       Web server is healthy: http://localhost:3000
echo [3/3] Starting the Cloudflare Quick Tunnel...

set "TUNNEL_RUNNING="
for /F "delims=" %%S in ('docker inspect --format "{{.State.Running}}" loopinity-tunnel 2^>nul') do set "TUNNEL_RUNNING=%%S"

if /I "!TUNNEL_RUNNING!"=="true" (
  echo       Reusing the running Tunnel.
  goto :wait_for_url
)

docker rm -f loopinity-tunnel >nul 2>&1
docker run -d --name loopinity-tunnel cloudflare/cloudflared:latest tunnel --no-autoupdate --protocol http2 --url http://host.docker.internal:3000 >nul
if errorlevel 1 (
  echo [ERROR] Could not start the Cloudflare Tunnel.
  goto :failed
)

:wait_for_url
set "TUNNEL_URL="
for /L %%I in (1,1,40) do (
  for /F "tokens=2 delims=|" %%A in ('docker logs loopinity-tunnel 2^>^&1 ^| findstr /C:".trycloudflare.com"') do (
    for /F "tokens=1" %%B in ("%%A") do set "TUNNEL_URL=%%B"
  )
  if defined TUNNEL_URL goto :success
  timeout /t 1 /nobreak >nul
)

echo [ERROR] Could not read the public URL.
echo Review the Tunnel logs below.
docker logs --tail 40 loopinity-tunnel
goto :failed

:success
powershell.exe -NoProfile -Command "Set-Clipboard -Value '!TUNNEL_URL!'" >nul 2>&1
echo.
echo ============================================================
echo   LOOPINITY IS NOW PUBLIC
echo.
echo   !TUNNEL_URL!
echo.
echo   The URL has been copied to the Windows clipboard.
echo   You may close this window. The containers will keep running.
echo   Run stop-public.bat to shut down the website and Tunnel.
echo ============================================================
echo.
pause
exit /b 0

:failed
echo.
echo Startup failed. Review the error message above.
echo.
pause
exit /b 1
