@echo off
rem Default BPC 2 two-phase validation
rem
rem Syntax: validate validadte-xml-file

if     "a%~1" == "a" goto :args

if not exist "%~1" goto :badxml

echo.
echo ############################################################
echo Validating remittance
echo ############################################################

if exist "%~1.error.txt" del "%~1.error.txt"
if exist "%~1.svrl.xml" del "%~1.svrl.xml"

echo ===== Phase 1: XSD schema validation =====
call "%~dp0/val/w3cschema.bat" "%~dp0remt.001.001.05.xsd" "%~1" > "%~1.error.txt"
set errorRet=%errorlevel%
if %errorRet% neq 0 goto :error
echo No schema validation errors.
del "%~1.error.txt"

echo ===== Phase 2: Remittance "%~1" data integrity validation =====
call "%~dp0/val/xslt.bat" "%~1" "%~dp0remt.001.001.05_dbnalliance_v1.0.xsl" "%~1.svrl.xml" 2> "%~1.error.txt"
set errorRet=%errorlevel%
if %errorRet% neq 0 goto :error
del "%~1.error.txt"

call "%~dp0/val/xslt.bat" "%~1.svrl.xml" "%~dp0testSVRL4UBLerrors.xsl" nul 2>"%~1.error.txt"
set errorRet=%errorlevel%
if %errorRet% neq 0 goto :error

echo No data integrity validation errors.
goto :done

:args
echo Syntax:  validate.bat remittance-xml-file
goto :done

:badxml
echo Input XML file not found: "%~1"
goto :done

:error
type "%~1.error.txt"

:done
del "%~1.svrl.xml"
del "%~1.error.txt"
exit /B %errorRet%