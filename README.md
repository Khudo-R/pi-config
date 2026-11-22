# Pi Agent Configuration (`pi-config`)

Portable configuration, instructions, and automated environment deployment for the [Pi](https://github.com/obra/pi) coding agent.

## Repository Contents

- `settings.json` - Declares installed packages, default provider (`google`), default model (`gemini-3.1-pro-preview`), and thinking level (`medium`).
- `config.json` - Fallback chains (`gemini-4-argon` → `gemini-3.8-flash` → `claude-sonnet-5-5`), model options, and plugin rules.
- `SYSTEM.md` - System instructions and operational guidelines for agent behavior.
- `setup.ps1` - PowerShell setup script for Windows (installs prerequisites, deploys configs, installs all 10 extensions).
- `setup.sh` - Bash setup script for Linux/macOS/Git Bash.
- `.gitignore` - Strict exclusion list protecting secrets (`auth.json`, `antigravity-accounts.json`), session history, and runtime caches.

## Installed Extensions

This setup comes preconfigured with the following 10 extensions:

| Extension | Source | Description |
| :--- | :--- | :--- |
| **`superpowers`** | `git:github.com/obra/superpowers` | Engineering skill framework (TDD, systematic debugging, code reviews, planning, brainstorming). |
| **`@a5c-ai/babysitter-pi`** | `npm:@a5c-ai/babysitter-pi` | Workflow orchestration framework for complex, multi-step processes with event-sourced state and human-in-the-loop controls. |
| **`context-mode`** | `npm:context-mode` | Context-window optimizer providing sandboxed execution, FTS5 search, and cross-session resume. |
| **`pi-hashline-edit-pro`** | `npm:pi-hashline-edit-pro` | Hash-anchored file editing tools (`read`, `replace`, `insert`, `grep`) ensuring safe, deterministic edits. |
| **`pi-lsp-adapter`** | `npm:pi-lsp-adapter` | Language Server Protocol (LSP) integration providing semantic diagnostics, hover, definitions, and symbol search. |
| **`pi-mem`** | `npm:pi-mem` | Persistent memory extension capturing observations, compressing notes, and querying past session memories. |
| **`@raquezha/antigravity`** | `npm:@raquezha/antigravity` | OAuth login provider extension for Google Antigravity models. |
| **`pi-antigravity`** | `npm:pi-antigravity` | Cloud Code Assist / Antigravity provider adapter for Pi. |
| **`pi-token-speed`** | `npm:pi-token-speed` | Real-time token generation speed tracker (tokens/second) using a sliding window. |
| **`pi-token-usage-statistics`**| `npm:pi-token-usage-statistics`| Token usage, cost estimation, and cache-hit statistics dashboard across sessions. |

---

## Quick Start on a New Machine

### 1. Clone this repository
```powershell
git clone https://github.com/Khudo-R/pi-config.git D:\projects\pi-config
cd D:\projects\pi-config
```

### 2. Run Setup

**On Windows (PowerShell):**
```powershell
# Standard deployment (copies config files and installs all extensions)
.\setup.ps1

# Or deploy with symbolic links
.\setup.ps1 -Method Symlink
```

**On Linux / macOS / Git Bash:**
```bash
chmod +x setup.sh
./setup.sh
```

### 3. Authenticate
Configure your API keys or run `/login` (or `pi auth login`) inside Pi.

---

> **Security Note:** Never commit `auth.json`, `antigravity-accounts.json`, or the `sessions/` directory. These are excluded by `.gitignore` by default.
