#!/usr/bin/env sh

GOLANG="golang:1.26.2-bookworm"
DIR="$(realpath "$(dirname "$0")")"

for OSARCH in linux:amd64 android:arm64; do
    OS="${OSARCH%:*}"
    ARCH="${OSARCH#*:}"
    echo "$ARCH / $OS"
    for APP in 1 2; do
        docker run --rm \
            -e GOARCH="$ARCH" \
            -e GOOS="$OS" \
            -e CGO_ENABLED=0 \
            -w /app \
            -v "$DIR":/app \
            "$GOLANG" \
            go build -trimpath -ldflags="-w -s -buildid=" -o ./app."$ARCH"."$APP".bin ./app"$APP"/app"$APP".go \
            || exit 1
    done
done
echo OK
