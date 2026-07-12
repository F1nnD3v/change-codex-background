# Change Codex Background

An unofficial, reversible runtime theme that gives the Codex desktop app an anime background without modifying its signed installation.

![Anime background preview](codex-anime-background.png?raw=1&v=2)

## Requirements

- Codex must be completely closed before using a launcher.
- macOS and Linux require Node.js 22 or newer.
- The desktop build must accept Chromium/Electron command-line arguments.

## Windows

Double-click **Start Codex Anime Theme.bat**.

The Windows launcher uses the Node.js runtime bundled with Codex, so a separate Node.js installation is not required.

## macOS

Open Terminal in this folder and run:

```bash
chmod +x start-codex-anime-theme.macos.sh
./start-codex-anime-theme.macos.sh
```

The launcher checks `/Applications` and `~/Applications`. If Codex is installed somewhere else:

```bash
CODEX_APP="/path/to/Codex.app" ./start-codex-anime-theme.macos.sh
```

## Linux

Executable installation:

```bash
chmod +x start-codex-anime-theme.linux.sh
CODEX_EXE="/path/to/Codex" ./start-codex-anime-theme.linux.sh
```

AppImage:

```bash
CODEX_APPIMAGE="$HOME/Applications/Codex.AppImage" ./start-codex-anime-theme.linux.sh
```

Flatpak:

```bash
CODEX_FLATPAK_APP="your.flatpak.app.id" ./start-codex-anime-theme.linux.sh
```

## Remove the theme

Close Codex and start it normally. Nothing is permanently installed or patched.

## Security and compatibility

The launcher opens a Chromium debugging connection on localhost port `9223` while Codex is running so it can inject the theme. Other software running under your user account may be able to access that local connection. Use the normal Codex shortcut for sensitive sessions.

Codex updates may change its internal interface and require adjustments to the injected CSS. The macOS and Linux launchers are compatibility launchers and require an existing Electron-based Codex desktop installation; they do not install Codex itself.

This project is unofficial and is not affiliated with or endorsed by OpenAI.
