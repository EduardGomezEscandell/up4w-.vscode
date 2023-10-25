$commit = "$(git rev-parse HEAD~1)"
$root = "C:\Users\edu19\Work\ubuntu-pro-for-windows"
$repo = "github.com/canonical/ubuntu-pro-for-windows"

$modules = @()
Get-ChildItem -Path "${root}" -Recurse -Filter go.mod | ForEach-Object {
    $modules += $(Split-Path -Parent $_)
}

$batch = Get-Random -Max 999

ForEach ($p in ${modules}) {
    $mod = "$(Split-Path -Leaf $p)"
    Start-Job -Name "${batch}-${mod}" -ScriptBlock {
        Push-Location "${using:p}"

        foreach ($p in ${using:modules}) {
            $mod = "$(Split-Path -Leaf $p)"
            if ("$mod" -eq "${using:mod}") {
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
