& "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1" -SkipAutomaticLocation

$wapproj = ".\msix\UbuntuProForWindows\UbuntuProForWindows.wapproj"
$certificate = "083D237292AC491DD1893E440172181791554DFC"

(Get-Content -Path "${wapproj}")                                                        `
    -replace                                                                            `
        "<PackageCertificateThumbprint>.*</PackageCertificateThumbprint>",              `
        "<PackageCertificateThumbprint>${certificate}</PackageCertificateThumbprint>"   `
    | Set-Content -Path "${wapproj}"

msbuild                                              `
    .\msix\msix.sln                                  `
    -target:Build                                    `
    -maxCpuCount                                     `
    -nodeReuse:false                                 `
    -property:Configuration=Release                  `
    -property:AppxBundle=Always                      `
    -property:AppxBundlePlatforms=x64                `
    -property:UapAppxPackageBuildMode=SideloadOnly   `
    -nologo                                          `
    -verbosity:normal

if (! $?) {
    exit 1
}

$destination = (
    Get-ChildItem ".\msix\UbuntuProForWindows\AppPackages\UbuntuProForWindows_*"    `
    | Sort-Object LastWriteTime                                                     `
    | Select-Object -last 1                                                         `
)

Write-Output "The AppxPackage can be found at $destination"