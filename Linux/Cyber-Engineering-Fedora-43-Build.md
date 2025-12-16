# Cyber-Engineering Fedora 43 Build 

Here is a detailed breakdown of setting up our Workstaion up with a "Cyber" feel and tools that we'll use with pentesting :)

## 1. The "Cyber" Core (The Brain)

### Shell: Switched from Bash to Zsh + Oh My Zsh.

- Features: Auto-suggestions (ghost text) and syntax highlighting.

### Prompt: Installed Starship with the "Tokyo Night" preset.

- Customization: Configured to work inside Warp Terminal without extra spacing.

### Fonts: Installed jetbrains-mono Nerd Fonts to support all the dev icons.

## 2. The Dev Arsenal (The Tools)

### IDE: Cursor (AI Code Editor).

- Setup: Manual AppImage install in /opt/cursor.
- Customization: Replaced the default icon with a custom "Cyber Arrow" (and fixed the issue where it was a random guy's face).

### Terminal: Warp.

- Setup: Added the official RPM repo (after wget failed on the direct link).
- Config: Set to "Shell Prompt" to respect your Starship theme.

### Virtualization: KVM/QEMU (via virt-manager).

- Why: Native speed for pentesting VMs (Kali).
- Fix: Manually installed packages because DNF5 on Fedora 43 didn't like the @virtualization group tag.

## 3. Daily Drivers & Utilities

### Productivity: Todoist (Snap).

### Music: Spotify (Flatpak).

### Screenshots: Flameshot.

- Fix: Installed legacy tray support and forced the Wayland execution flag so it could capture the screen.

### System Tools: Btop (monitor), Tldr (manuals), and RPM Fusion (codecs).

## The Troubleshooting Log (War Stories)

### Snapd Error: Todoist failed with "too early for operation."

- Fix: We verified the seeding status (snap debug seeding) and waited for the background service to generate its keys.

### Warp Download: The initial wget command downloaded a 9kb HTML file instead of the RPM.

- Fix: We added the official Warp repository for a clean install and updates.

### Flameshot on Wayland: The app wouldn't launch or capture the screen.

- Fix: We installed gnome-shell-extension-appindicator and libappindicator-gtk3 to give it a system tray to live in.

### DNF5 Syntax: dnf groupinstall failed.

- Fix: We switched to explicit package installation (qemu-kvm libvirt ...) which is more reliable on Rawhide/F43.

