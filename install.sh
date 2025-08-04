#!/bin/bash

set -e

# Better Touch Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/OwlfaceGames/better_touch/main/install.sh | bash

REPO="OwlfaceGames/better_touch"
BINARY_NAME="btouch"
INSTALL_DIR="/usr/local/bin"
TEMP_DIR=$(mktemp -d)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect OS and architecture
detect_platform() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)
    
    case $os in
        linux*)
            OS="linux"
            ;;
        darwin*)
            OS="macos"
            ;;
        *)
            print_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
    
    case $arch in
        x86_64|amd64)
            ARCH="x86_64"
            ;;
        arm64|aarch64)
            ARCH="arm64"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    print_status "Detected platform: $OS-$ARCH"
}

# Function to get the latest release version
get_latest_version() {
    print_status "Fetching latest release information..."
    
    # Try to get latest release from GitHub API
    if command -v curl >/dev/null 2>&1; then
        VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    elif command -v wget >/dev/null 2>&1; then
        VERSION=$(wget -qO- "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    else
        print_error "Neither curl nor wget is available. Please install one of them."
        exit 1
    fi
    
    if [ -z "$VERSION" ]; then
        print_error "Failed to get latest version. Using 'latest' as fallback."
        VERSION="latest"
    else
        print_status "Latest version: $VERSION"
    fi
}

# Function to download the binary
download_binary() {
    print_status "Downloading $BINARY_NAME..."
    
    # Construct download URL
    if [ "$VERSION" = "latest" ]; then
        DOWNLOAD_URL="https://github.com/$REPO/releases/latest/download/${BINARY_NAME}-${OS}-${ARCH}"
    else
        DOWNLOAD_URL="https://github.com/$REPO/releases/download/${VERSION}/${BINARY_NAME}-${OS}-${ARCH}"
    fi
    
    # Fallback URLs for different naming conventions
    FALLBACK_URLS=(
        "https://github.com/$REPO/releases/latest/download/${BINARY_NAME}"
        "https://github.com/$REPO/releases/latest/download/${BINARY_NAME}_${OS}_${ARCH}"
        "https://github.com/$REPO/releases/latest/download/${BINARY_NAME}-${OS}"
    )
    
    print_status "Download URL: $DOWNLOAD_URL"
    
    # Try to download the binary from primary URL
    download_success=false
    
    # Primary download attempt
    if command -v curl >/dev/null 2>&1; then
        if curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/$BINARY_NAME" 2>/dev/null; then
            download_success=true
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q "$DOWNLOAD_URL" -O "$TEMP_DIR/$BINARY_NAME" 2>/dev/null; then
            download_success=true
        fi
    else
        print_error "Neither curl nor wget is available."
        exit 1
    fi
    
    # If primary download failed, try fallback URLs
    if [ "$download_success" = false ]; then
        print_warning "Primary download failed, trying fallback URLs..."
        for fallback_url in "${FALLBACK_URLS[@]}"; do
            print_status "Trying: $fallback_url"
            if command -v curl >/dev/null 2>&1; then
                if curl -fsSL "$fallback_url" -o "$TEMP_DIR/$BINARY_NAME" 2>/dev/null; then
                    download_success=true
                    break
                fi
            elif command -v wget >/dev/null 2>&1; then
                if wget -q "$fallback_url" -O "$TEMP_DIR/$BINARY_NAME" 2>/dev/null; then
                    download_success=true
                    break
                fi
            fi
        done
    fi
    
    # If all downloads failed, try compiling from source
    if [ "$download_success" = false ] || [ ! -f "$TEMP_DIR/$BINARY_NAME" ] || [ ! -s "$TEMP_DIR/$BINARY_NAME" ]; then
        print_warning "Pre-compiled binary not found. Attempting to compile from source..."
        compile_from_source
    fi
    
    # Make binary executable
    chmod +x "$TEMP_DIR/$BINARY_NAME"
    print_success "Downloaded $BINARY_NAME"
}

# Function to compile from source if binary download fails
compile_from_source() {
    print_status "Checking for required tools..."
    
    # Check if gcc is available
    if ! command -v gcc >/dev/null 2>&1; then
        print_error "gcc is not installed. Please install a C compiler."
        exit 1
    fi
    
    print_status "Downloading source code..."
    
    # Download main.c
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "https://raw.githubusercontent.com/$REPO/main/main.c" -o "$TEMP_DIR/main.c"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "https://raw.githubusercontent.com/$REPO/main/main.c" -O "$TEMP_DIR/main.c"
    fi
    
    if [ ! -f "$TEMP_DIR/main.c" ]; then
        print_error "Failed to download source code"
        exit 1
    fi
    
    print_status "Compiling $BINARY_NAME..."
    cd "$TEMP_DIR"
    gcc -std=c99 main.c -o "$BINARY_NAME"
    
    if [ ! -f "$BINARY_NAME" ]; then
        print_error "Compilation failed"
        exit 1
    fi
    
    print_success "Compiled $BINARY_NAME from source"
}

# Function to install the binary
install_binary() {
    print_status "Installing $BINARY_NAME to $INSTALL_DIR..."
    
    # Check if we have write permission to install directory
    if [ ! -w "$(dirname "$INSTALL_DIR")" ]; then
        print_status "Requesting elevated permissions for installation..."
        sudo mv "$TEMP_DIR/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
        sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"
    else
        mv "$TEMP_DIR/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
        chmod +x "$INSTALL_DIR/$BINARY_NAME"
    fi
    
    print_success "Installed $BINARY_NAME to $INSTALL_DIR"
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    if command -v "$BINARY_NAME" >/dev/null 2>&1; then
        print_success "$BINARY_NAME is now available in your PATH"
        print_status "Try running: $BINARY_NAME .txt readme notes todo"
    else
        print_warning "$BINARY_NAME installed but not found in PATH. You may need to restart your shell."
        print_status "Binary location: $INSTALL_DIR/$BINARY_NAME"
    fi
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}

# Main installation function
main() {
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║         Better Touch Installer      ║"
    echo "║                                      ║"
    echo "║  A smarter version of touch command  ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    
    # Trap to ensure cleanup on exit
    trap cleanup EXIT
    
    detect_platform
    get_latest_version
    download_binary
    install_binary
    verify_installation
    
    echo ""
    print_success "Installation completed successfully!"
    echo ""
    echo "Usage examples:"
    echo "  $BINARY_NAME .txt readme notes todo    # Creates readme.txt, notes.txt, todo.txt"
    echo "  $BINARY_NAME .js app utils config      # Creates app.js, utils.js, config.js"
    echo "  $BINARY_NAME _test file1 file2         # Creates file1_test, file2_test"
    echo ""
    echo "For more information, visit: https://github.com/$REPO"
    echo ""
}

# Run main function
main "$@"