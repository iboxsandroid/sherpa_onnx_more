@echo off
setlocal

rem 发布到 Maven Central
rem 用法:
rem   build.bat publish 4.85
rem   build.bat local 4.85
rem
rem 发布前需要准备以下环境变量:
rem   ORG_GRADLE_PROJECT_mavenCentralUsername
rem   ORG_GRADLE_PROJECT_mavenCentralPassword
rem   ORG_GRADLE_PROJECT_signingInMemoryKeyId
rem   ORG_GRADLE_PROJECT_signingInMemoryKey
rem   ORG_GRADLE_PROJECT_signingInMemoryKeyPassword

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

set ACTION=%~1
set VERSION=%~2

if "%ACTION%"=="" goto :usage

if not "%VERSION%"=="" (
	set GRADLE_VERSION_ARG=-PVERSION_NAME=%VERSION%
) else (
	set GRADLE_VERSION_ARG=
)

if /I "%ACTION%"=="publish" goto :publish
if /I "%ACTION%"=="local" goto :local
if /I "%ACTION%"=="bundle" goto :bundle

goto :usage

:bundle
call gradlew.bat :library:assembleRelease %GRADLE_VERSION_ARG%
goto :end

:local
call gradlew.bat :library:publishAarPublicationToMavenLocal %GRADLE_VERSION_ARG%
goto :end

:publish
call :checkEnv ORG_GRADLE_PROJECT_mavenCentralUsername
call :checkEnv ORG_GRADLE_PROJECT_mavenCentralPassword
call :checkEnv ORG_GRADLE_PROJECT_signingInMemoryKeyId
call :checkEnv ORG_GRADLE_PROJECT_signingInMemoryKey
call :checkEnv ORG_GRADLE_PROJECT_signingInMemoryKeyPassword
if errorlevel 1 goto :end

call gradlew.bat :library:publishAndReleaseToMavenCentral %GRADLE_VERSION_ARG%
goto :end

:checkEnv
if "%~1"=="" exit /b 1
call set VALUE=%%%~1%%
if "%VALUE%"=="" (
	echo Missing env: %~1
	exit /b 1
)
exit /b 0

:usage
echo Usage:
echo   build.bat publish [version]
echo   build.bat local [version]
echo   build.bat bundle [version]
echo.
echo Examples:
echo   build.bat bundle 4.85
echo   build.bat local 4.85
echo   build.bat publish 4.85
exit /b 1

:end
exit /b %errorlevel%
