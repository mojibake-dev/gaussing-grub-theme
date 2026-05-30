#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load configuration
source "${SCRIPT_DIR}/config.sh"

# Determine font file and internal name
FONT_FILE="vcr_osd_mono_${FONT_SIZE}.pf2"
FONT_NAME="VCR OSD Mono Regular ${FONT_SIZE}"

if [[ ! -f "${SCRIPT_DIR}/fonts/${FONT_FILE}" ]]; then
    echo "Error: Font file fonts/${FONT_FILE} not found."
    echo "Available sizes: 16, 24, 32, 36, 48, 64"
    exit 1
fi

# Check for root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (sudo ./install.sh)"
    exit 1
fi

echo "Installing gaussing GRUB theme..."
echo "  Font size: ${FONT_SIZE}pt"
echo "  Timeout:   ${TIMEOUT}s"
echo "  Resolution: ${GRUB_RESOLUTION}"
echo "  Install to: ${INSTALL_DIR}"
echo ""

# Create theme directory
mkdir -p "${INSTALL_DIR}"

# Generate theme.txt from template
sed \
    -e "s|%%FONT_NAME%%|${FONT_NAME}|g" \
    -e "s|%%HUD_COLOR%%|${HUD_COLOR}|g" \
    -e "s|%%MENU_COLOR%%|${MENU_COLOR}|g" \
    -e "s|%%SELECTED_COLOR%%|${SELECTED_COLOR}|g" \
    -e "s|%%DECK_LABEL%%|${DECK_LABEL}|g" \
    "${SCRIPT_DIR}/theme/theme.txt.template" > "${INSTALL_DIR}/theme.txt"

# Copy background
cp "${SCRIPT_DIR}/theme/background.png" "${INSTALL_DIR}/"

# Copy selected font to theme dir and grub fonts dir
cp "${SCRIPT_DIR}/fonts/${FONT_FILE}" "${INSTALL_DIR}/"
cp "${SCRIPT_DIR}/fonts/${FONT_FILE}" "/boot/grub/fonts/"

# Update /etc/default/grub
GRUB_CFG="/etc/default/grub"

set_grub_var() {
    local key="$1" value="$2"
    if grep -q "^${key}=" "$GRUB_CFG"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$GRUB_CFG"
    elif grep -q "^#${key}=" "$GRUB_CFG"; then
        sed -i "s|^#${key}=.*|${key}=${value}|" "$GRUB_CFG"
    else
        echo "${key}=${value}" >> "$GRUB_CFG"
    fi
}

set_grub_var "GRUB_THEME" "\"${INSTALL_DIR}/theme.txt\""
set_grub_var "GRUB_TIMEOUT" "${TIMEOUT}"
set_grub_var "GRUB_TIMEOUT_STYLE" "menu"
set_grub_var "GRUB_GFXMODE" "${GRUB_RESOLUTION}"

# Update GRUB
echo "Updating GRUB configuration..."
if command -v update-grub &>/dev/null; then
    update-grub
elif command -v grub-mkconfig &>/dev/null; then
    grub-mkconfig -o /boot/grub/grub.cfg
elif command -v grub2-mkconfig &>/dev/null; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
else
    echo "Warning: Could not find update-grub or grub-mkconfig."
    echo "You may need to regenerate your GRUB config manually."
fi

echo ""
echo "Done! Reboot to see the theme."
echo "If the font doesn't render, try a different FONT_SIZE in config.sh."
