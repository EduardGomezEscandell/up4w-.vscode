#!/bin/bash
set -eu

COVDIR="/tmp/coverage"
mkdir -p "$COVDIR"

echo "Running go test..."

go test ./... -tags=gowslmock -covermode=set -coverprofile "${COVDIR}/coverage.out" -coverpkg=./... -parallel 1
go tool cover -o "${COVDIR}/index.html" -html "${COVDIR}/coverage.out"

echo ""
echo "Done. Run the following command to see the coverage:"
echo "python3 -m http.server 8000 --directory ${COVDIR}"
