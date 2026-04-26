#!/usr/bin/env bash

if ! command -v docker &> /dev/null; then
    echo "$(basename "$0"): docker not found, skip"
    exit
fi

script_dir="$(dirname "$(realpath "$0")")"
container="$1"
cd "$script_dir/../"

docker cp "$PWD" "$container":/root/
infocmp | docker exec -i "$container" tic -
