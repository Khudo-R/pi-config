<#
.SYNOPSIS
    Automated environment setup script for the Pi agent and all installed extensions.

.DESCRIPTION
    1. Verifies prerequisites (Node.js, Git).
    2. Checks for Pi CLI; installs or adds ~/.pi/agent/bin to PATH if needed.
    3. Deploys settings.json, config.json, and SYSTEM.md into ~/.pi/agent (with automated backup).
    4. Explicitly installs and validates all 10 agent extensions using `pi install`.
    5. Displays the active extensions list (`pi list`).

.PARAMETER Method
    Deployment method for config files: 'Copy' (default) or 'Symlink'.

.PARAMETER SkipExtensions
    Skip running `pi install` for each extension (relies on Pi auto-installing from settings.json on launch).

.PARAMETER TargetDir
    Target directory for Pi agent files (defaults to $env:USERPROFILE\.pi\agent).
#>

[CmdletBinding()]
param (
    [ValidateSet("Copy", "Symlink")]
    [string]$Method = "Copy",

    [switch]$SkipExtensions = $false,

    [string]$TargetDir = "$env:USERPROFILE\.pi\agent"
)

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "       Pi Agent Environment Setup        " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check Prerequisites
Write-Host "[1/5] Checking prerequisites..." -ForegroundColor Yellow

# Node.js
try {
    $nodeVersion = node --version 2>$null
    Write-Host " [OK] Node.js is installed ($nodeVersion)" -ForegroundColor Green
}
catch {
    Write-Warning "Node.js was not detected on PATH. Node.js 22.19.0+ is required by Pi."
}

# Git
try {
    $gitVersion = git --version 2>$null
    Write-Host " [OK] Git is installed ($gitVersion)" -ForegroundColor Green
}
catch {
    Write-Warning "Git was not detected on PATH. Git is required for git-based extensions like superpowers."
}

# 2. Check / Setup Pi CLI
Write-Host "`n[2/5] Checking Pi CLI..." -ForegroundColor Yellow
$piCmd = Get-Command pi -ErrorAction SilentlyContinue

if (-not $piCmd) {
    $piBinPath = Join-Path $TargetDir "bin"
    $piExe = Join-Path $piBinPath "pi.cmd"
    if (Test-Path $piExe) {
        Write-Host " Found Pi binary at $piBinPath. Adding to current process PATH." -ForegroundColor DarkGray
        $env:PATH = "$piBinPath;$env:PATH"
    }
    else {
        Write-Host " Pi CLI not found. You can install it using:" -ForegroundColor DarkYellow
        Write-Host "   powershell -ExecutionPolicy ByPass -c `"irm https://pi.dev/install.ps1 | iex`"" -ForegroundColor Gray
    }
}
else {
    Write-Host " [OK] Pi CLI available: $($piCmd.Source)" -ForegroundColor Green
}

# 3. Ensure Target Directory & Deploy Configurations
Write-Host "`n[3/5] Deploying configuration files ($Method)..." -ForegroundColor Yellow

if (-not (Test-Path -Path $TargetDir)) {
    Write-Host " Creating target directory: $TargetDir" -ForegroundColor DarkGray
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

$sourceDir = $PSScriptRoot
$configFiles = @("settings.json", "config.json", "SYSTEM.md")

foreach ($file in $configFiles) {
    $sourcePath = Join-Path $sourceDir $file
    $destPath   = Join-Path $TargetDir $file

    if (-not (Test-Path -Path $sourcePath)) {
        Write-Warning "Source file not found: $sourcePath, skipping."
        continue
    }

    if (Test-Path -Path $destPath) {
        $sourceContent = Get-Content -Raw -Path $sourcePath
        $destContent   = Get-Content -Raw -Path $destPath

        if ($sourceContent -ne $destContent) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupPath = "$destPath.bak_$timestamp"
            Write-Host " Backing up existing $file -> $file.bak_$timestamp" -ForegroundColor DarkGray
            Copy-Item -Path $destPath -Destination $backupPath -Force
        }
    }

    if ($Method -eq "Symlink") {
        try {
            if (Test-Path -Path $destPath) {
                Remove-Item -Path $destPath -Force
            }
            New-Item -ItemType SymbolicLink -Path $destPath -Target $sourcePath -Force | Out-Null
            Write-Host " [Symlink] $file -> $destPath" -ForegroundColor Green
        }
        catch {
            Write-Warning "Symlink failed ($($_.Exception.Message)). Falling back to Copy."
            Copy-Item -Path $sourcePath -Destination $destPath -Force
            Write-Host " [Copy]    $file -> $destPath" -ForegroundColor Green
        }
    }
    else {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host " [Copy]    $file -> $destPath" -ForegroundColor Green
    }
}

# 4. Install Extensions
Write-Host "`n[4/5] Installing / verifying extensions..." -ForegroundColor Yellow

$extensions = @(
    "npm:@a5c-ai/babysitter-pi",
    "npm:pi-antigravity",
    "npm:context-mode",
    "npm:pi-hashline-edit-pro",
    "npm:pi-lsp-adapter",
    "npm:pi-mem",
    "npm:pi-token-speed",
    "npm:pi-token-usage-statistics",
    "git:github.com/obra/superpowers",
    "npm:@raquezha/antigravity"
)

if ($SkipExtensions) {
    Write-Host " Skipping explicit extension install (-SkipExtensions specified)." -ForegroundColor DarkGray
}
else {
    $canRunPi = (Get-Command pi -ErrorAction SilentlyContinue) -or (Test-Path (Join-Path $TargetDir "bin\pi.cmd"))
    if ($canRunPi) {
        foreach ($ext in $extensions) {
            Write-Host " Installing/updating extension: $ext" -ForegroundColor DarkCyan
            try {
                pi install $ext
            }
            catch {
                Write-Warning "Failed running 'pi install $ext': $($_.Exception.Message)"
            }
        }
    }
    else {
        Write-Host " Pi binary not directly callable in this shell. Extensions listed in settings.json" -ForegroundColor DarkYellow
        Write-Host " will automatically be installed on first run of 'pi'." -ForegroundColor DarkYellow
    }
}

# 5. Summary & Verification
Write-Host "`n[5/5] Setup Summary & Verification" -ForegroundColor Yellow

try {
    Write-Host "`nListing installed extensions in Pi:" -ForegroundColor Cyan
    pi list
}
catch {
    Write-Host " Run 'pi list' to inspect installed extensions." -ForegroundColor DarkGray
}

Write-Host "`n=========================================" -ForegroundColor Green
Write-Host "      Pi Setup Completed Successfully!   " -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Next steps:"
Write-Host "  1. Authenticate your providers: run 'pi auth login' or enter your API keys."
Write-Host "  2. Launch Pi in your workspace: run 'pi'."
