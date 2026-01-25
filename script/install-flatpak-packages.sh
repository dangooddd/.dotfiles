#!/usr/bin/env sh

script_dir="$(cd "$(dirname "$0")" && pwd)"
package_dir="$(cd "$script_dir/../misc/packages" && pwd)"

flatpak mask org.freedesktop.Platform.openh264
xargs flatpak install -y < "$package_dir/flatpak.txt"
