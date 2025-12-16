#!/bin/bash
# ==========================================
# Kenny's Cyber Fedora 43 Setup Script (v4)
# Automated via Gemini
# Includes: Virtualization, Warp, Cursor, Zsh, Fastfetch, Btop, Tldr, Apps
# 
# NOTE: This script is optimized for a Dell Precision 5770 running Fedora 43
# ==========================================

set -e # Exit immediately if a command fails

echo "🚀 Starting Master Setup for Cybersecurity Engineering..."

# --- PHASE 1: SYSTEM PREP & POWER TOOLS ---
echo "📦 Updating repositories..."
sudo dnf upgrade --refresh -y

echo "🛠️  Installing Base Dependencies..."
sudo dnf install -y git curl wget util-linux-user fuse fuse-libs

echo "⚡ Installing CLI Power Tools (Fastfetch, Btop, Tldr)..."
sudo dnf install -y fastfetch btop tldr

# --- PHASE 2: CODECS (RPM FUSION) ---
echo "🎬 Configuring RPM Fusion..."
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf group upgrade -y core
sudo dnf group upgrade -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf group upgrade -y sound-and-video

# --- PHASE 3: VIRTUALIZATION (KVM) ---
echo "🖥️  Installing KVM Virtualization..."
# Using explicit packages to avoid DNF5 group issues on Fedora 43
sudo dnf install -y qemu-kvm libvirt virt-manager virt-install libvirt-daemon-config-network libguestfs-tools

# Enable services & add user to group
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $(whoami)
echo "✅ Virtualization active."

# --- PHASE 4: CYBER TOOLS (WARP & CURSOR) ---
echo "🚀 Installing Warp Terminal..."
sudo rpm --import https://releases.warp.dev/linux/keys/warp.asc
sudo sh -c 'echo -e "[warpdotdev]\nname=warpdotdev\nbaseurl=https://releases.warp.dev/linux/rpm/stable\nenabled=1\ngpgcheck=1\ngpgkey=https://releases.warp.dev/linux/keys/warp.asc" > /etc/yum.repos.d/warpdotdev.repo'
sudo dnf install -y warp-terminal

echo "🧠 Installing Cursor IDE..."
CURSOR_DIR="/opt/cursor"
sudo mkdir -p "$CURSOR_DIR"
# Download AppImage (Generic link)
wget -O /tmp/cursor.AppImage "https://downloader.cursor.sh/linux/appImage/x64"
sudo mv /tmp/cursor.AppImage "$CURSOR_DIR/cursor.AppImage"
sudo chmod +x "$CURSOR_DIR/cursor.AppImage"
# Download Official Icon
sudo curl -L "https://avatars.githubusercontent.com/u/126756637?s=200&v=4" -o "$CURSOR_DIR/cursor.png"
# Create Desktop Entry
cat <<EOF | sudo tee /usr/share/applications/cursor.desktop
[Desktop Entry]
Name=Cursor
Exec=$CURSOR_DIR/cursor.AppImage --no-sandbox %F
Icon=$CURSOR_DIR/cursor.png
Type=Application
Categories=Development;
MimeType=text/plain;
EOF
sudo update-desktop-database

# --- PHASE 5: UTILITIES (FLAMESHOT) ---
echo "🔥 Installing Flameshot & Legacy Tray Support..."
sudo dnf install -y flameshot gnome-shell-extension-appindicator libappindicator-gtk3

# --- PHASE 6: APPS (SNAP & FLATPAK) ---
echo "🎵 Installing Snap, Todoist & Spotify..."
sudo dnf install -y snapd
sudo ln -s /var/lib/snapd/snap /snap || true
sudo systemctl enable --now snapd.socket

# WAIT LOOP: Fix for "too early for operation" error
echo "⏳ Waiting for Snapd to seed (preventing installation errors)..."
while ! sudo snap debug seeding | grep -q "seeded:.*true"; do
    echo "   ...still seeding, waiting 3 seconds..."
    sleep 3
done
echo "✅ Snapd is seeded!"

# Install Todoist
sudo snap install todoist
sudo snap install gtk-common-themes

# Install Spotify (Flatpak)
echo "🎧 Installing Spotify..."
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub com.spotify.Client

# --- PHASE 7: SHELL (ZSH + STARSHIP) ---
echo "🐚 Setting up Zsh & Starship..."
sudo dnf install -y zsh
# Install Starship
curl -sS https://starship.rs/install.sh | sh -s -- -y
# Install Oh My Zsh (Unattended)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
# Install Plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true

# Configure .zshrc
echo "📝 Writing .zshrc config..."
cat <<EOF > ~/.zshrc
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source \$ZSH/oh-my-zsh.sh
eval "\$(starship init zsh)"
alias cursor="/opt/cursor/cursor.AppImage --no-sandbox"
EOF

# Configure Starship (Tokyo Night)
mkdir -p ~/.config
starship preset tokyo-night -o ~/.config/starship.toml
starship config add_newline false

# Change Shell
echo "🔄 Changing default shell to Zsh..."
sudo usermod -s /bin/zsh $(whoami)

echo "=========================================="
echo "🎉 MASTER SETUP COMPLETE!"
echo "Please RESTART your computer now."
echo "=========================================="

