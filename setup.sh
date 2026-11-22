#!/usr/bin/env bash
#
# Automated setup script for Pi agent configuration and extensions on Linux/macOS/Git Bash.
#

set -e

PI_TARGET_DIR="${PI_TARGET_DIR:-$HOME/.pi/agent}"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "       Pi Agent Environment Setup        "
echo "========================================="
echo ""

# 1. Check Prerequisites
echo "[1/5] Checking prerequisites..."
if command -v node >/dev/null 2>&1; then
    echo " [OK] Node.js is installed ($(node -v))"
else
    echo " [WARN] Node.js is not found on PATH. Node.js 22.19.0+ is required by Pi." >&2
fi

if command -v git >/dev/null 2>&1; then
    echo " [OK] Git is installed ($(git --version))"
else
    echo " [WARN] Git is not found on PATH. Required for git-based extensions like superpowers." >&2
fi

# 2. Check Pi CLI
echo ""
echo "[2/5] Checking Pi CLI..."
if command -v pi >/dev/null 2>&1; then
    echo " [OK] Pi CLI available: $(which pi)"
elif [ -f "$PI_TARGET_DIR/bin/pi" ]; then
    export PATH="$PI_TARGET_DIR/bin:$PATH"
    echo " [OK] Added $PI_TARGET_DIR/bin to PATH"
else
    echo " [INFO] Pi CLI not found. Install via: curl -fsSL https://pi.dev/install.sh | bash"
fi

# 3. Deploy Configuration Files
echo ""
echo "[3/5] Deploying configuration files to $PI_TARGET_DIR..."
mkdir -p "$PI_TARGET_DIR"

CONFIG_FILES=("settings.json" "config.json" "SYSTEM.md")
for file in "${CONFIG_FILES[@]}"; do
    src="$SOURCE_DIR/$file"
    dst="$PI_TARGET_DIR/$file"

    if [ ! -f "$src" ]; then
        echo " [WARN] Source file $src not found, skipping."
        continue
    fi

    if [ -f "$dst" ] && ! cmp -s "$src" "$dst"; then
        timestamp=$(date +"%Y%m%d_%H%M%S")
        echo " Backing up existing $file -> $file.bak_$timestamp"
        cp "$dst" "$dst.bak_$timestamp"
    fi

    cp "$src" "$dst"
    echo " [Copy] $file -> $dst"
done

# 4. Install Extensions
echo ""
echo "[4/5] Installing / verifying extensions..."
EXTENSIONS=(
    "npm:@a5c-ai/babysitter-pi"
    "npm:pi-antigravity"
    "npm:context-mode"
    "npm:pi-hashline-edit-pro"
    "npm:pi-lsp-adapter"
    "npm:pi-mem"
    "npm:pi-token-speed"
    "npm:pi-token-usage-statistics"
    "git:github.com/obra/superpowers"
    "npm:@raquezha/antigravity"
)

if command -v pi >/dev/null 2>&1; then
    for ext in "${EXTENSIONS[@]}"; do
        echo " Installing extension: $ext"
        pi install "$ext" || true
    done
else
    echo " Pi binary not directly callable; extensions defined in settings.json"
    echo " will be automatically installed on first run of 'pi'."
fi

# 5. Summary & Verification
echo ""
echo "[5/5] Setup Summary & Verification"
if command -v pi >/dev/null 2>&1; then
    echo ""
    echo "Listing installed extensions in Pi:"
    pi list || true
fi

echo ""
echo "========================================="
echo "      Pi Setup Completed Successfully!   "
echo "========================================="
echo "Next steps:"
echo "  1. Authenticate providers: 'pi auth login' or configure API keys."
echo "  2. Launch Pi in your project: 'pi'."
