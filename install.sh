#!/bin/bash
# Installs the Starship themes and the time-of-day scheduler for the current user.
#
#   ./install.sh             install and switch to Starship now
#   ./install.sh --no-apply  install without changing the current theme

set -euo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
THEMES="$HOME/.config/omarchy/themes"
HOOKS="$HOME/.config/omarchy/hooks"
UNITS="$HOME/.config/systemd/user"
BIN="$HOME/.local/bin"

if ! command -v omarchy-theme-set >/dev/null; then
  echo "Omarchy was not found. This installer needs an Omarchy system." >&2
  exit 1
fi

mkdir -p "$THEMES" "$HOOKS/post-boot.d" "$HOOKS/theme-set.d" "$UNITS" "$BIN"

for theme in "$REPO"/themes/starship-*; do
  rm -rf "$THEMES/$(basename "$theme")"
  cp -r "$theme" "$THEMES/"
done

install -m 755 "$REPO/bin/starship-dynamic" "$BIN/starship-dynamic"
install -m 755 "$REPO/hooks/post-boot.d/starship-dynamic" "$HOOKS/post-boot.d/starship-dynamic"
install -m 755 "$REPO/hooks/theme-set.d/starship-dynamic" "$HOOKS/theme-set.d/starship-dynamic"
install -m 644 "$REPO"/systemd/starship-dynamic.{service,timer} "$UNITS/"

systemctl --user daemon-reload
systemctl --user enable --now starship-dynamic.timer >/dev/null

echo "Installed Starship Dynamic."

if [[ ${1:-} != --no-apply ]]; then
  # The theme-set hook moves this to the theme and frame for the current time.
  omarchy-theme-set starship-day >/dev/null
  echo "Switched to the Starship theme for the current time."
else
  echo "Pick any Starship theme with: omarchy theme set starship-day"
fi
