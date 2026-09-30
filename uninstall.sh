#!/bin/bash
# Removes the Starship themes and the time-of-day scheduler.

set -euo pipefail

systemctl --user disable --now starship-dynamic.timer >/dev/null 2>&1 || true
rm -f "$HOME"/.config/systemd/user/starship-dynamic.{service,timer}
systemctl --user daemon-reload

rm -f "$HOME/.local/bin/starship-dynamic" \
  "$HOME/.config/omarchy/hooks/post-boot.d/starship-dynamic" \
  "$HOME/.config/omarchy/hooks/theme-set.d/starship-dynamic"
rm -rf "$HOME"/.config/omarchy/themes/starship-{day,golden,night}

echo "Removed Starship Dynamic."

if [[ $(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null) == starship-* ]]; then
  echo "A Starship theme is still applied. Pick another with: omarchy theme set <name>"
fi
