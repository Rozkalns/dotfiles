# Linux Scripts

Automation scripts for Linux servers (Ubuntu/Debian).

## Scripts

### motd.sh
Installs a custom Message of the Day (MOTD) that displays update notifications when you SSH into servers.

**Usage:**
```bash
make motd
# or
./linux/motd.sh
```

**What it shows:**
- Number of available package updates
- Suggestion to run `topgrade` (or `apt update/upgrade` if topgrade not installed)
- Reboot required warnings (with package names that triggered it)
- System uptime

**Example output when you SSH in:**
```
╔═══════════════════════════════════════════════════════════════╗
║  📦 23 package update(s) available
║
║  Run: topgrade
╚═══════════════════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════════════════╗
║  🔴 REBOOT REQUIRED
║
║  Run: sudo reboot
║  Reason: linux-image-generic, systemd
╚═══════════════════════════════════════════════════════════════╝

Uptime: 14 days, 3 hours, 22 minutes
```

**Installation location:**
- Installs to: `/etc/update-motd.d/99-custom-update-reminder`
- Requires sudo to install

**Test the MOTD:**
```bash
# See what it will display
run-parts /etc/update-motd.d/

# Or just SSH into the server
ssh user@server
```

## Files

### 99-custom-update-reminder
The actual MOTD script that gets installed to `/etc/update-motd.d/`.

**How it works:**
- Runs automatically when you SSH into the server
- Checks `apt list --upgradable` for available updates
- Checks `/var/run/reboot-required` for reboot needs
- Color-coded output (yellow for updates, red for reboot)
- Shows up to 3 packages that triggered the reboot requirement

## Workflow

1. **Install dotfiles on server:**
   ```bash
   git clone git@github.com:Rozkalns/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   make
   ```

2. **MOTD installs automatically** (part of Linux install)

3. **SSH into server** - you'll see update notifications

4. **Run updates when ready:**
   ```bash
   topgrade
   # or
   sudo apt update && sudo apt upgrade
   ```

5. **Reboot if needed:**
   ```bash
   sudo reboot
   ```

## Notes

- MOTD only works on Ubuntu/Debian (uses `/etc/update-motd.d/`)
- Does NOT automatically update packages (manual only)
- Perfect for Forge servers, Raspberry Pi, and VPS instances
- Compatible with topgrade - shows "Run: topgrade" if installed
