$COVDIR = "C:\Temp\coverage"

Write-Output "Running go test..."

# We put the output through a file because WSL messes up the newlines
go.exe test -tags=gowslmock  -v ./... -covermode=set -coverprofile "${COVDIR}\coverage.out" -coverpkg=./... *> "${COVDIR}\test.log"
$RESULT_TEST = $?

Get-Content "${COVDIR}\test.log"

Write-Output ""
Write-Output "Running go tool cover..."

go.exe tool cover -o "${COVDIR}\index.html" -html "${COVDIR}\coverage.out"
$RESULT_COVER = $?

if ( "${RESULT_TEST}" -eq "$False" -or "${RESULT_COVER}" -eq "$False" ) {
    exit 1
}

Write-Output ""
Write-Output "Done. Run the following command to see the coverage:"
Write-Output "python -m http.server 8000 --directory ${COVDIR}"
