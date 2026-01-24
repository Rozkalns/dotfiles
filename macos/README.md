# macOS Scripts

Automation scripts for macOS system configuration.

## Scripts

### dock.sh
Configures the macOS Dock with preferred applications.

**Usage:**
```bash
make dock
# or
./macos/dock.sh
```

### phpstorm.sh
Configures PhpStorm with JetBrainsMono Nerd Font for editor, terminal, and console.

**Usage:**
```bash
make phpstorm
# or
./macos/phpstorm.sh
```

### topgrade-launchagent.sh
Installs a LaunchAgent to run `topgrade` daily at 3:00 AM for automatic system updates.

**Usage:**
```bash
make topgrade-agent
# or
./macos/topgrade-launchagent.sh
```

**What it updates:**
- Homebrew packages (CLI tools)
- Homebrew casks (GUI apps like PhpStorm, Rectangle, Raycast, etc.)
  - Note: Docker is excluded (requires password)
- npm global packages
- composer global packages
- Git repositories
- And more (configured in `config/topgrade/topgrade.toml`)

**Logs:**
- `~/topgrade_stdout.log` - Standard output
- `~/topgrade_stderr.log` - Error output

**Manual run:**
```bash
topgrade --yes
```

**Test LaunchAgent:**
```bash
launchctl start com.user.topgrade
```

## LaunchAgents

### com.user.topgrade.plist
LaunchAgent configuration for automated topgrade updates at 3:00 AM daily.

Features:
- Runs daily at 3:00 AM
- Sends macOS notifications on start/finish
- Includes retry logic (retries after 30 seconds if first attempt fails)
- Low priority (nice level 1) to not interfere with system performance
- Logs all output for troubleshooting

**Note:** Replaces the old `com.user.brewupdate.plist` which only updated Homebrew. Topgrade updates everything.
