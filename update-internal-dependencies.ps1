$commit = "5b9d0e7eff848477bfa51647cbee727cc80ca48f"
$root = "C:\Users\edu19\Work\ubuntu-pro-for-wsl"
$repo = "github.com/canonical/ubuntu-pro-for-wsl"

Set-Location $root

$modulePaths = @()
Get-ChildItem -Path "${root}" -Recurse -Filter "go.mod" | ForEach-Object {
    $modulePaths += $(Split-Path -Parent $_.FullName)
}

$batch = Get-Random -Max 999

ForEach ($p in ${modulePaths}) {
    $job = "$(Split-Path -Leaf $p)"
    $mod = (${p}).Replace("${root}","${repo}").Replace('\','/')

    Start-Job -Name "${batch}-${job}" -ScriptBlock {
        Push-Location "${using:p}"
        $deps = $(go mod edit -json | jq -r '.Require[] | select(.Path | startswith("github.com/canonical/ubuntu")) | .Path')
        foreach ($mod in ${deps}) {
            go get "${mod}@${using:commit}"
        }
			
        go mod tidy

        Pop-Location
    }
}

ForEach ($p in ${modulePaths}) {
    $job = "$(Split-Path -Leaf $p)"
    Wait-Job -Name "${batch}-${job}"
    Receive-Job -Name "${batch}-${job}"
}
