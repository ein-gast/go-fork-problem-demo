#!/usr/bin/env sh

for ARCH in amd64 arm64; do
echo "$ARCH"
GOARCH="$ARCH" GOOS=linux CGO_ENABLED=0 go build -trimpath -ldflags="-w -s" -o ./app1."$ARCH".bin ./app1/app1.go
GOARCH="$ARCH" GOOS=linux CGO_ENABLED=0 go build -trimpath -ldflags="-w -s" -o ./app2."$ARCH".bin ./app2/app2.go 
done