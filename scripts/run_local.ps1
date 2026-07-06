$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DataDirectory = Join-Path $ProjectRoot 'data'
$MainDatabase = Join-Path $DataDirectory 'warehouse.db'

New-Item -ItemType Directory -Force -Path $DataDirectory | Out-Null
$env:DBT_SQLITE_MAIN_DB = $MainDatabase
$env:DBT_SQLITE_SCHEMA_DIR = $DataDirectory

Push-Location $ProjectRoot
try {
    dbt debug --profiles-dir .
    dbt seed --full-refresh --profiles-dir .
    dbt build --profiles-dir .
    dbt docs generate --profiles-dir .
}
finally {
    Pop-Location
}
