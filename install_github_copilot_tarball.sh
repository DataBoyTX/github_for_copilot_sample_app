#!/usr/bin/env bash
# Install GitHub Copilot CLI from tarball for version 0.0.400 on Linux (Ubuntu 22.04 and WSL2 friendly).
# This script automatically detects your platform (amd64/arm64), downloads the appropriate tarball,
# installs the binary, and optionally authenticates.
#
# Usage:
#   sudo ./install_copilot_from_tarball.sh       # installs and authenticates
#   sudo ./install_copilot_from_tarball.sh --no-auth  # installs but skips authentication

set -euo pipefail

# Configuration
REPO="github/copilot-cli"
TAG="v0.0.400"
ARCH="$(uname -m)"
TMP_DIR="$(mktemp -d)"
SKIP_AUTH=0
TARBALL=""

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Argument parsing
for arg in "$@"; do
    case "$arg" in
        --no-auth) SKIP_AUTH=1 ;;
        *) echo "Unknown argument: $arg"; exit 1 ;;
    esac
done

# Detect architecture
case "$ARCH" in
    x86_64 | amd64) PLATFORM="x64" ;;
    aarch64 | arm64) PLATFORM="arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac
echo "Detected platform: $PLATFORM"

# Determine tarball URL
TARBALL_URL="https://github.com/$REPO/releases/download/$TAG/copilot-linux-$PLATFORM.tar.gz"
TARBALL="$TMP_DIR/copilot-linux.tar.gz"

# Download the tarball
echo "Downloading GitHub Copilot CLI tarball from $TARBALL_URL"
curl -L -o "$TARBALL" "$TARBALL_URL"

# Extract the tarball
echo "Extracting GitHub Copilot CLI tarball..."
tar -xzf "$TARBALL" -C "$TMP_DIR"

# Move the binary to /usr/local/bin
echo "Installing GitHub Copilot CLI binary..."
sudo mv "$TMP_DIR/copilot" /usr/local/bin/
sudo chmod +x /usr/local/bin/copilot

# Verify installation
if command -v copilot >/dev/null 2>&1; then
    echo "GitHub Copilot CLI successfully installed. Version:"
    copilot --version
else
    echo "Installation failed: 'copilot' binary not found. Please investigate."
    exit 1
fi

# Authentication step: updated to match the latest GitHub Copilot CLI requirements.
if [ "$SKIP_AUTH" -eq 0 ]; then
    if [ -t 1 ]; then
        echo
        echo "Running 'copilot -i auth login' for interactive authentication..."
        if ! copilot -i "auth login"; then
            echo "Authentication failed or was cancelled. Run 'copilot -i \"auth login\"' later to authenticate."
        fi
    else
        echo "Non-interactive shell detected. Authentication must be run manually. Use:"
        echo "    copilot auth login --prompt"
    fi
else
    echo "Authentication skipped (--no-auth). To authenticate later, run:"
    echo "    copilot auth login --prompt"
fi


echo "Installation complete."
