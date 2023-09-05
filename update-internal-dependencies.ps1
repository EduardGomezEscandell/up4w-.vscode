$commit = "2ffba81b817ecde0e0d3d368bfdb40688a934da8"
$root = "C:\Users\edu19\Work\ubuntu-pro-for-windows"
$repo = "github.com/canonical/ubuntu-pro-for-windows"

    
$modules = @()
Get-ChildItem -Path "${root}" | ForEach-Object {
    if ( Test-Path -Path "${root}\$_\go.mod" ) {
        $modules += "$_"
    } 
}


$batch = Get-Random -Max 999

ForEach ($job in ${modules}) {
    Start-Job -Name "${batch}-${job}" -ScriptBlock {
        Push-Location "${using:root}\${using:job}"

        foreach ($mod in ${using:modules}) {
            if ("$mod" -eq "${using:job}") {
                continue
            }

            go get "${using:repo}/${mod}@${using:commit}"
        }
			
        go mod tidy

        Pop-Location
    }
}

ForEach ($job in $modules) {
    Wait-Job -Name "${batch}-${job}"
    Receive-Job -Name "${batch}-${job}"
}
