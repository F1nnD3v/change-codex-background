#!/usr/bin/env bash
set -euo pipefail

theme_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
image_path="$theme_dir/codex-anime-background.png"
injector_path="$theme_dir/inject-theme.js"
port="${CODEX_THEME_PORT:-9223}"
node_bin="${NODE_BIN:-node}"

for required_file in "$image_path" "$injector_path"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing required file: $required_file" >&2
    exit 1
  fi
done

if ! command -v "$node_bin" >/dev/null 2>&1; then
  echo "Node.js 22 or newer is required. Install Node.js, then run this launcher again." >&2
  exit 1
fi

if ! "$node_bin" -e 'process.exit(typeof fetch === "function" && typeof WebSocket === "function" ? 0 : 1)'; then
  echo "Node.js 22 or newer is required because the theme injector uses built-in fetch and WebSocket." >&2
  exit 1
fi

debug_args=(
  "--remote-debugging-port=$port"
  "--remote-allow-origins=http://127.0.0.1:$port"
)

if [[ -n "${CODEX_FLATPAK_APP:-}" ]]; then
  flatpak run "$CODEX_FLATPAK_APP" "${debug_args[@]}" >/dev/null 2>&1 &
elif [[ -n "${CODEX_APPIMAGE:-}" ]]; then
  if [[ ! -x "$CODEX_APPIMAGE" ]]; then
    echo "CODEX_APPIMAGE is not executable: $CODEX_APPIMAGE" >&2
    exit 1
  fi
  "$CODEX_APPIMAGE" "${debug_args[@]}" >/dev/null 2>&1 &
else
  codex_exe="${CODEX_EXE:-}"
  if [[ -z "$codex_exe" ]]; then
    for candidate in \
      "/opt/Codex/codex" \
      "/opt/Codex/Codex" \
      "/opt/ChatGPT/chatgpt" \
      "/opt/ChatGPT/ChatGPT" \
      "$HOME/.local/bin/codex-desktop" \
      "$HOME/.local/bin/chatgpt-desktop"; do
      if [[ -x "$candidate" ]]; then
        codex_exe="$candidate"
        break
      fi
    done
  fi

  if [[ -z "$codex_exe" || ! -x "$codex_exe" ]]; then
    echo "Could not find a Codex desktop executable." >&2
    echo "Set one of these and try again:" >&2
    echo '  CODEX_EXE="/path/to/Codex" ./start-codex-anime-theme.linux.sh' >&2
    echo '  CODEX_APPIMAGE="/path/to/Codex.AppImage" ./start-codex-anime-theme.linux.sh' >&2
    echo '  CODEX_FLATPAK_APP="your.flatpak.app.id" ./start-codex-anime-theme.linux.sh' >&2
    exit 1
  fi

  "$codex_exe" "${debug_args[@]}" >/dev/null 2>&1 &
fi

sleep 1
"$node_bin" "$injector_path" "$image_path" "$port"
