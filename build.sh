#!/usr/bin/env sh

for ARCH in amd64 arm64; do
    echo "$ARCH"
    GOARCH="$ARCH" GOOS=linux   CGO_ENABLED=0 go build -trimpath -ldflags="-w -s -buildid=" -o ./app."$ARCH".1.bin ./app1/app1.go
    GOARCH="$ARCH" GOOS=android CGO_ENABLED=0 go build -trimpath -ldflags="-w -s -buildid=" -o ./app."$ARCH".2.bin ./app2/app2.go 
done
echo OK
