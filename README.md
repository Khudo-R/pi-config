# Pi Agent Configuration (`pi-config`)

Portable configuration templates and package declarations for the [Pi](https://github.com/obra/pi) coding agent.

## Repository Contents

- `settings.json` - Declares installed packages (`superpowers`, `babysitter-pi`, `context-mode`, etc.), default provider (`google`), default model, and thinking level.
- `config.json` - Model fallback chains, error recovery behaviors, and plugin options.
- `SYSTEM.md` - System instructions and operational guidelines for agent behavior.
- `setup.ps1` - PowerShell deployment script to deploy these files into `~/.pi/agent/`.
- `.gitignore` - Strict exclusion list for secrets (`auth.json`, `antigravity-accounts.json`), session history, and runtime caches.

## Quick Start on a New Machine

### 1. Clone this repository
```powershell
git clone <your-repo-url> D:\projects\pi-config
cd D:\projects\pi-config
```

### 2. Deploy Configuration
Run the setup script:

```powershell
# Copy files into ~/.pi/agent/ (creates backups if files already exist)
.\setup.ps1

# Or create symlinks (requires Developer Mode or Administrator privileges)
.\setup.ps1 -Method Symlink
```

### 3. Launch Pi
Run `pi`. It will read `settings.json` and automatically install any declared npm / git packages.

```powershell
pi
```

### 4. Authenticate
Configure your API keys or run `/login` inside Pi to generate your local `auth.json`.

---

> **Security Note:** Never commit `auth.json`, `antigravity-accounts.json`, or the `sessions/` directory. These are excluded by `.gitignore` by default.
