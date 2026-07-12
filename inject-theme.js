const fs = require("node:fs");

const imagePath = process.argv[2];
const port = Number(process.argv[3] || 9223);

if (!imagePath || !fs.existsSync(imagePath)) {
  console.error("Background image not found:", imagePath || "(missing path)");
  process.exit(1);
}

const image = fs.readFileSync(imagePath).toString("base64");
const css = `
:root, :root.electron-dark {
  --startup-background: transparent !important;
  --color-background-surface: rgb(7 11 25 / 0.70) !important;
  --color-background-surface-under: rgb(4 8 20 / 0.82) !important;
  --color-background-elevated-primary: rgb(17 23 42 / 0.88) !important;
  --color-background-elevated-primary-opaque: rgb(17 23 42 / 0.94) !important;
  --color-background-elevated-secondary: rgb(255 255 255 / 0.055) !important;
  --color-background-elevated-secondary-opaque: rgb(22 29 49 / 0.92) !important;
  --color-background-editor-opaque: rgb(8 13 29 / 0.72) !important;
  --color-token-main-surface-primary: rgb(7 11 25 / 0.70) !important;
  --color-token-side-bar-background: rgb(4 8 20 / 0.82) !important;
  --color-token-bg-primary: rgb(7 11 25 / 0.70) !important;
  --color-token-bg-secondary: rgb(17 23 42 / 0.78) !important;
  --vscode-editor-background: rgb(8 13 29 / 0.72) !important;
  --vscode-sideBar-background: rgb(4 8 20 / 0.82) !important;
}
html, body, #root {
  background-color: transparent !important;
}
body {
  background-image:
    linear-gradient(90deg, rgb(2 5 16 / 0.48), rgb(2 5 16 / 0.20)),
    url("data:image/png;base64,${image}") !important;
  background-size: cover !important;
  background-position: center !important;
  background-attachment: fixed !important;
}
`;

const install = `(() => {
  const id = "codex-anime-background-theme";
  let style = document.getElementById(id);
  if (!style) {
    style = document.createElement("style");
    style.id = id;
    document.head.appendChild(style);
  }
  style.textContent = ${JSON.stringify(css)};
  return true;
})()`;

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function targets() {
  const response = await fetch(`http://127.0.0.1:${port}/json`);
  if (!response.ok) throw new Error(`Debug endpoint returned ${response.status}`);
  return response.json();
}

function inject(target) {
  return new Promise((resolve, reject) => {
    const socket = new WebSocket(target.webSocketDebuggerUrl);
    const timer = setTimeout(() => {
      socket.close();
      reject(new Error("Theme injection timed out"));
    }, 15000);

    socket.addEventListener("open", () => {
      socket.send(JSON.stringify({
        id: 1,
        method: "Page.addScriptToEvaluateOnNewDocument",
        params: { source: install },
      }));
      socket.send(JSON.stringify({
        id: 2,
        method: "Runtime.evaluate",
        params: { expression: install, returnByValue: true },
      }));
    });

    socket.addEventListener("message", (event) => {
      const message = JSON.parse(event.data);
      if (message.id !== 2) return;
      clearTimeout(timer);
      socket.close();
      if (message.error || message.result?.exceptionDetails) {
        reject(new Error("Codex rejected the theme injection"));
      } else {
        resolve();
      }
    });
    socket.addEventListener("error", () => reject(new Error("Could not connect to Codex")));
  });
}

async function main() {
  for (let attempt = 0; attempt < 40; attempt += 1) {
    try {
      const pages = (await targets()).filter(
        (target) => target.type === "page" && target.webSocketDebuggerUrl,
      );
      if (pages.length) {
        for (const page of pages) await inject(page);
        console.log("Anime background applied. Keep using this launcher to start Codex with the theme.");
        process.exit(0);
      }
    } catch {}
    await sleep(500);
  }

  console.error("Codex did not expose its local theme connection. Close Codex fully and try again.");
  process.exit(1);
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
