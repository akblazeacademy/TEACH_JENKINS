#!/bin/bash
set -e

USER="jenkins"
SUDO_FILE="/etc/sudoers.d/$USER"

echo "🔐 Adding $USER to sudoers..."

# Ensure user exists
if ! id "$USER" &>/dev/null; then
  echo "❌ User $USER does not exist"
  exit 1
fi

# Create sudoers file
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "$SUDO_FILE" > /dev/null

# Set correct permissions
sudo chmod 440 "$SUDO_FILE"

# Validate sudoers syntax
sudo visudo -cf "$SUDO_FILE"

echo "✅ Jenkins user added to sudoers successfully"
