#!/usr/bin/env pwsh
#Requires -PSEdition Core
#Requires -Version 7.0

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$TestName
)

$ErrorActionPreference = 'Stop'

$testFile = "test-$TestName.zil"
$zilfExe = Join-Path $PSScriptRoot "../../bin/Debug/net10.0/zilf.exe"
$zapfExe = Join-Path $PSScriptRoot "../../bin/Debug/net10.0/zapf.exe"
$czlrExe = Join-Path $PSScriptRoot "ConsoleZLR.exe"

if (-not (Test-Path $testFile)) {
    Write-Error "Couldn't find $testFile."
    exit 1
}

if (-not (Test-Path $zilfExe)) {
    Write-Error "Couldn't find zilf.exe under ../../bin/Debug/net10.0. Build the solution first."
    exit 1
}

if (-not (Test-Path $zapfExe)) {
    Write-Error "Couldn't find zapf.exe under ../../bin/Debug/net10.0. Build the solution first."
    exit 1
}

if (-not (Test-Path $czlrExe)) {
    Write-Error "Couldn't find ConsoleZLR.exe in the current directory. Copy it (and its DLLs) from the ZLR distribution first."
    exit 1
}

& $zilfExe -ip .. -d $testFile
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $zapfExe "test-$TestName.zap"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $czlrExe -dumb2 -debug "test-$TestName.z3" "test-$TestName.dbg"
