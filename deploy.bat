@echo off
echo ==========================
echo BUILD FLUTTER WEB
echo ==========================

call flutter build web
if errorlevel 1 goto error

echo.
echo ==========================
echo UPLOAD TO SERVER
echo ==========================

scp -r build\web\* root@217.198.12.145:/var/www/manibase-web/
if errorlevel 1 goto error

echo.
echo ==========================
echo FIX PERMISSIONS + RELOAD NGINX
echo ==========================

ssh root@217.198.12.145 "find /var/www/manibase-web -type d -exec chmod 755 {} \; && find /var/www/manibase-web -type f -exec chmod 644 {} \; && systemctl reload nginx"
if errorlevel 1 goto error

echo.
echo ==========================
echo DEPLOY SUCCESSFUL
echo ==========================
pause
exit /b 0

:error
echo.
echo ==========================
echo DEPLOY FAILED
echo ==========================
pause
exit /b 1