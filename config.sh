#!/usr/bin/env bash
# gaussing-grub-theme configuration
# Edit these variables before running install.sh

# Font size (available: 16, 24, 32, 36, 48, 64)
# Recommended: 24 for 1080p, 36 for 720p, 48+ for lower resolutions
FONT_SIZE=36

# GRUB timeout in seconds (the VCR countdown timer)
TIMEOUT=9

# GRUB graphics mode resolution
# Lower resolution = larger text. 1280x720 is a good balance.
GRUB_RESOLUTION="1280x720"

# VCR HUD text color
HUD_COLOR="#cccccc"

# Boot menu colors
MENU_COLOR="#999999"
SELECTED_COLOR="#ffffff"

# VCR deck label (top-left corner)
DECK_LABEL="Deck 1"

# Installation directory
INSTALL_DIR="/boot/grub/themes/gaussing"
