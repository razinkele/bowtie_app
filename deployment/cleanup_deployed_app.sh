#!/bin/bash
# =============================================================================
# Cleanup Script - Remove System Directories from Deployed App
# Version: 1.0
#
# This script removes accidentally deployed system directories from the
# Shiny Server app directory, keeping only legitimate application files.
# =============================================================================

set -e

APP_DEST_DIR="/srv/shiny-server/bowtie_app"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║   Cleanup System Directories from Deployed App               ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root: sudo $0${NC}"
    exit 1
fi

# Check current size
echo -e "${BLUE}Current directory size:${NC}"
du -sh "${APP_DEST_DIR}"
echo ""

# List of system directories that should NOT be in an app directory
SYSTEM_DIRS=(
    "home"
    "boot"
    "dev"
    "etc"
    "proc"
    "sys"
    "root"
    "run"
    "tmp"
    "var"
    "usr"
    "bin"
    "sbin"
    "lib"
    "lib64"
    "opt"
    "mnt"
    "media"
    "srv"
    "cdrom"
    "lost+found"
    "timeshift"
    "bin.usr-is-merged"
    "sbin.usr-is-merged"
    "lib.usr-is-merged"
)

echo -e "${YELLOW}${BOLD}WARNING:${NC} This will remove the following directories from ${APP_DEST_DIR}:"
echo ""

SPACE_TO_FREE=0
for dir in "${SYSTEM_DIRS[@]}"; do
    if [ -d "${APP_DEST_DIR}/${dir}" ]; then
        SIZE=$(du -sh "${APP_DEST_DIR}/${dir}" 2>/dev/null | cut -f1)
        SIZE_BYTES=$(du -sb "${APP_DEST_DIR}/${dir}" 2>/dev/null | cut -f1)
        SPACE_TO_FREE=$((SPACE_TO_FREE + SIZE_BYTES))
        echo -e "  ${RED}✗${NC} ${dir}/ (${SIZE})"
    fi
done

echo ""
SPACE_TO_FREE_HUMAN=$(numfmt --to=iec-i --suffix=B ${SPACE_TO_FREE} 2>/dev/null || echo "${SPACE_TO_FREE} bytes")
echo -e "${YELLOW}Total space to be freed: ${BOLD}${SPACE_TO_FREE_HUMAN}${NC}"
echo ""

# Ask for confirmation
read -p "Are you sure you want to delete these directories? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${BLUE}Cleanup cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${CYAN}Starting cleanup...${NC}"
echo ""

# Remove system directories
REMOVED_COUNT=0
FAILED_COUNT=0

for dir in "${SYSTEM_DIRS[@]}"; do
    if [ -d "${APP_DEST_DIR}/${dir}" ]; then
        echo -e "  ${BLUE}[....]${NC} Removing ${dir}/..."
        if rm -rf "${APP_DEST_DIR}/${dir}" 2>/dev/null; then
            echo -e "  ${GREEN}[DONE]${NC} Removed ${dir}/"
            REMOVED_COUNT=$((REMOVED_COUNT + 1))
        else
            echo -e "  ${RED}[FAIL]${NC} Failed to remove ${dir}/"
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    fi
done

echo ""
echo -e "${GREEN}${BOLD}Cleanup Summary:${NC}"
echo -e "  Removed: ${GREEN}${REMOVED_COUNT}${NC} directories"
echo -e "  Failed:  ${RED}${FAILED_COUNT}${NC} directories"
echo ""

# Show final size
echo -e "${BLUE}New directory size:${NC}"
du -sh "${APP_DEST_DIR}"
echo ""

# Show what remains
echo -e "${BLUE}Remaining contents:${NC}"
ls -lh "${APP_DEST_DIR}" | grep "^d" | awk '{print "  " $9}' | head -20
echo ""

echo -e "${GREEN}${BOLD}Cleanup complete!${NC}"
