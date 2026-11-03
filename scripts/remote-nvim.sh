#!/usr/bin/env bash

if [[ $# -ne 2 ]]; then
    echo "$(basename "$0"): pass <remote> and <path>"
    exit 1
fi

remote="$1"
path="${2//\'/\'\\\'\'}"
local_addr="127.0.0.1:1973"
remote_addr="127.0.0.1:1973"

if nc -z 127.0.0.1 1973 &> /dev/null; then
    echo "$(basename "$0"): port 1973 is already in use"
    exit 1
fi

ssh -o ExitOnForwardFailure=yes \
    -L "$local_addr:$remote_addr" \
    "$remote" "cd -- '$path' && exec nvim --headless --listen $remote_addr" &> /dev/null &

pid=$!
trap 'kill "$pid" &> /dev/null; wait "$pid" &> /dev/null' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

deadline=$((SECONDS + 60))
until nvim --server "$local_addr" --remote-expr '1' &> /dev/null; do
    if ! kill -0 "$pid" &> /dev/null; then
        echo "$(basename "$0"): remote nvim failed to start"
        exit 1
    fi
    if ((SECONDS >= deadline)); then
        echo "$(basename "$0"): connection timed out"
        exit 1
    fi
    sleep 1
done

nvim --server "$local_addr" --remote-ui
