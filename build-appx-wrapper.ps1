
param (
    [Parameter(Mandatory = $true, HelpMessage = "production, end_to_end_tests.")]
    [string]$Mode,

    [Parameter(Mandatory = $true, HelpMessage = "Path were to store the artifacts")]
    [string]$InstallPath
)

if ( "${mode}" -eq 'end_to_end_tests' ) {
    $env:UP4W_TEST_WITH_MS_STORE_MOCK = 1
}

powershell.exe -File .\tools\build\build-appx.ps1 -Mode ${mode}

if ( "$?" -ne "True" ) {
    Exit(1)
}

$artifacts = (
    Get-ChildItem ".\msix\UbuntuProForWSL\AppPackages\UbuntuProForWSL_*"    `
    | Sort-Object LastWriteTime                                                     `
    | Select-Object -last 1                                                         `
)

$certficate = Get-Item "${artifacts}\*.cer"
$package    = Get-Item "${artifacts}\*.msixbundle"

Write-Output "Copying ${certficate} into ${InstallPath}"
Copy-Item -Path "${certficate}" -Destination "${InstallPath}\certificate.cert"

Write-Output "Copying ${package} into ${InstallPath}"
Copy-Item -Path "${package}" -Destination "${InstallPath}\UbuntuProForWSL_${mode}.msixbundle"
