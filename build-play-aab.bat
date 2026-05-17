@echo off
setlocal

set "ROOT=%~dp0"
set "JAVA_HOME=%ROOT%..\tools\jdk-17"
set "ANDROID_HOME=%ROOT%..\tools\android-sdk"
set "ANDROID_SDK_ROOT=%ANDROID_HOME%"
set "PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin;%PATH%"

if not exist "%ROOT%android\upload-key.properties" (
  echo Falta android\upload-key.properties.
  echo Crea la upload key antes de generar el AAB de Google Play.
  pause
  exit /b 1
)

pushd "%ROOT%android"
call gradlew.bat bundleRelease
if errorlevel 1 (
  popd
  pause
  exit /b 1
)
popd

if not exist "%ROOT%artifact\old" mkdir "%ROOT%artifact\old"
for %%F in ("%ROOT%artifact\*Android*.aab") do move /Y "%%~fF" "%ROOT%artifact\old\" >nul
copy /Y "%ROOT%android\app\build\outputs\bundle\release\app-release.aab" "%ROOT%artifact\InspiracionDia-Android-v1.0-play-local.aab" >nul

echo AAB generado:
echo %ROOT%artifact\InspiracionDia-Android-v1.0-play-local.aab
endlocal
