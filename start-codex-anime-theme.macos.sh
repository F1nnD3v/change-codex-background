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

if [[ -n "${CODEX_EXE:-}" ]]; then
  if [[ ! -x "$CODEX_EXE" ]]; then
    echo "CODEX_EXE is not executable: $CODEX_EXE" >&2
    exit 1
  fi
  "$CODEX_EXE" "${debug_args[@]}" >/dev/null 2>&1 &
else
  app_path="${CODEX_APP:-}"
  if [[ -z "$app_path" ]]; then
    for candidate in \
      "/Applications/Codex.app" \
      "$HOME/Applications/Codex.app" \
      "/Applications/ChatGPT.app" \
      "$HOME/Applications/ChatGPT.app"; do
      if [[ -d "$candidate" ]]; then
        app_path="$candidate"
        break
      fi
    done
  fi

  if [[ -z "$app_path" || ! -d "$app_path" ]]; then
    echo "Could not find the Codex app." >&2
    echo "Set its location and try again, for example:" >&2
    echo '  CODEX_APP="/Applications/Codex.app" ./start-codex-anime-theme.macos.sh' >&2
    exit 1
  fi

  open -na "$app_path" --args "${debug_args[@]}"
fi

sleep 1
"$node_bin" "$injector_path" "$image_path" "$port"
