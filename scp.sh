#!/usr/bin/env sh

PHONE=default@127.0.0.1
PORT=22222

test -f .env && . ./.env

echo "Log in to $PHONE:$PORT..."
scp -o StrictHostKeyChecking=no -P "$PORT" ./*arm*.bin "$PHONE":~/
